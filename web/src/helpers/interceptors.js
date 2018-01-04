import axios from 'axios'
import store from '../store'
import router from '../router'
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default function setup () {
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
    return response
  }, (err) => {
    const originalRequest = err.config
    if (err.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      store.dispatch('auth/logout')
      return router.push({ name: 'login' })
    }
    return Promise.reject(err)
  })
}
