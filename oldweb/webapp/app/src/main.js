import Vue from 'vue'
import Electron from 'vue-electron'
import Resource from 'vue-resource'
import Router from 'vue-router'
import 'font-awesome/css/font-awesome.css'
import App from './App'
import routes from './routes'
import Bkitlogo from './Bkitlogo'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-default/index.css'
import locale from 'element-ui/lib/locale/lang/en'
// import VeeValidate from 'vee-validate'
// import AsyncComputed from 'vue-async-computed'

Vue.use(Electron)
Vue.use(Resource)
Vue.use(Router)
Vue.use(ElementUI, { locale })
Vue.config.debug = true
Vue.component('bkitlogo', Bkitlogo)
// Vue.use(VeeValidate)
// Vue.use(AsyncComputed)

const router = new Router({
  scrollBehavior: () => ({ y: 0 }),
  routes
})

/* eslint-disable no-new */
new Vue({
  router,
  ...App
}).$mount('#app')
