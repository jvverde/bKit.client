import axios from 'axios'
import store from 'src/store'
import router from 'src/router'
// import newServer from 'src/pages/newServer'

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
    console.error('Error:', err)
    const originalRequest = err.config
    const servername = store.getters['auth/servername']
    console.log('originalRequest:', originalRequest)
    if (err.response) {
      if (err.response.status === 400 && err.response.data && err.response.data.msg &&
        err.response.data.msg.match(/invalid.+user/i)) {
        store.dispatch('auth/logout')
      }
      if (err.response.status === 401 && !originalRequest._retry) {
        originalRequest._retry = true
        store.dispatch('auth/logout')
        router.replace({ name: 'login', query: {redirect: router.currentRoute.fullPath} })
        return new Promise((resolve) => promises.push(() => resolve(axios(originalRequest))))
      } else if (err.response.status === 404 && !servername) {
        // console.log(newServer)
        // newServer.render()
      }
    }
    return Promise.reject(err)
  })
}
