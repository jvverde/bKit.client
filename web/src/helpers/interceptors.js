import axios from 'axios'
import store from 'src/store'
import router from 'src/router'
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default function setup () {
  let promises = []
  axios.interceptors.request.use((config) => {
    const token = store.getters['auth/token']
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
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
    if (err.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      store.dispatch('auth/logout')
      router.replace({ name: 'login', query: {redirect: router.currentRoute.fullPath} })
      return new Promise((resolve) => promises.push(() => resolve(axios(originalRequest))))
    }
    return Promise.reject(err)
  })
}
