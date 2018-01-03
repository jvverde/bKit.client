import axios from 'axios'
import store from '../store'
import router from '../router'
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default function setup () {
  axios.interceptors.request.use((config) => {
    const token = store.getters['auth/token']
    console.log('token:', token)
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  }, (err) => Promise.reject(err))
  axios.interceptors.response.use((response) => {
    console.log('Response:', response)
    return response
  }, (err) => {
    const originalRequest = err.config
    console.log('originalRequest:', originalRequest)
    // return axios(originalRequest)
    // Promise.reject(err)
    if (err.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      store.dispatch('auth/logout')
      router.push({ name: 'login' })
    }
    return Promise.reject(err)
  })
}
