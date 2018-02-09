// === DEFAULT / CUSTOM STYLE ===
// WARNING! always comment out ONE of the two require() calls below.
// 1. use next line to activate CUSTOM STYLE (./src/themes)
// require(`./themes/app.${__THEME}.styl`)
// 2. or, use next line to activate DEFAULT QUASAR STYLE
require(`quasar/dist/quasar.${__THEME}.css`)
// ==============================

// Uncomment the following lines if you need IE11/Edge support
// require(`quasar/dist/quasar.ie`)
// require(`quasar/dist/quasar.ie.${__THEME}.css`)

import Vue from 'vue'
import Quasar from 'quasar'
import router from 'src/router'
import store from 'src/store'
import Bkitlogo from '@/Globals/Bkitlogo'
import Formateddate from '@/Globals/Formateddate'
import Formatedsize from '@/Globals/Formatedsize'
import Breadcrumb from '@/Globals/Breadcrumb'

Vue.config.productionTip = false
Vue.use(Quasar) // Install Quasar Framework

if (__THEME === 'mat') {
  require('quasar-extras/roboto-font')
}
import 'quasar-extras/material-icons'
// import 'quasar-extras/ionicons'
import 'quasar-extras/fontawesome'
// import 'quasar-extras/animate'

import Vuelidate from 'vuelidate'
Vue.use(Vuelidate)

import interceptorsSetup from 'src/helpers/interceptors'

interceptorsSetup()

import VueMoment from 'vue-moment'
import moment from 'moment-timezone'

moment.locale('en')
moment.relativeTimeThreshold('m', 119)
moment.relativeTimeThreshold('h', 47)
moment.relativeTimeThreshold('d', 59)
moment.relativeTimeThreshold('M', 23)

Vue.use(VueMoment, {
  moment
})

Vue.component('bkitlogo', Bkitlogo)
Vue.component('formateddate', Formateddate)
Vue.component('formatedsize', Formatedsize)
Vue.component('breadcrumb', Breadcrumb)

Quasar.start(() => {
  /* eslint-disable no-new */
  new Vue({
    el: '#q-app',
    router,
    store,
    render: h => h(require('./App').default)
  })
})
