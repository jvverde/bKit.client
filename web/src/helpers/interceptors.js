import axios from 'axios'
import store from 'src/store'
import router from 'src/router'
import addServer from 'src/helpers/addServer'

export default function setup () {
  let promises = []

  axios.interceptors.request.use((config) => {
    const token = store.getters['auth/token']
    const baseURL = store.getters['auth/baseURL']
    config.headers['X-bKit-API'] = 1
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    if (baseURL) {
      config.baseURL = baseURL
    }
    return config
  }, (err) => Promise.reject(err))

  axios.interceptors.response.use((response) => {
    if (response.headers['x-bkit-rtoken']) {
      store.dispatch('auth/token', response.headers['x-bkit-rtoken'])
    }
    if (response.data.login instanceof Object && response.data.login.token) {
      console.log('Login done', response.data.login)
      store.dispatch('auth/login', response.data.login)
      promises.forEach((promise) => promise())
      promises = []
    }
    return response
  }, (err) => {
    const originalRequest = err.config
    const servername = store.getters['auth/servername']

    if (err.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      store.dispatch('auth/logout')
      router.replace({ name: 'login', query: {redirect: router.currentRoute.fullPath} })
      return new Promise((resolve) => promises.push(() => resolve(axios(originalRequest))))
    } else if (err.response.status === 404 && !servername) {
      addServer()
    }
    return Promise.reject(err)
  })
}
