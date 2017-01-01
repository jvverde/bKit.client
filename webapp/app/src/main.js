import Vue from 'vue'
import Electron from 'vue-electron'
import Resource from 'vue-resource'
import Router from 'vue-router'
import 'materialize-css/dist/css/materialize.css'
import App from './App'
import routes from './routes'
import Bkitlogo from './Bkitlogo'

Vue.use(Electron)
Vue.use(Resource)
Vue.use(Router)
Vue.config.debug = true
Vue.component('bkitlogo', Bkitlogo)

const router = new Router({
  scrollBehavior: () => ({ y: 0 }),
  routes
})

/* eslint-disable no-new */
new Vue({
  router,
  ...App
}).$mount('#app')
