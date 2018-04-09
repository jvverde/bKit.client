<template>
  <div id="q-app">
    <router-view/>
  </div>
</template>

<script>
import Vue from 'vue'
import Bkitlogo from 'src/components/Globals/Bkitlogo'
import Formateddate from 'src/components/Globals/Formateddate'
import Formatedsize from 'src/components/Globals/Formatedsize'
import Breadcrumb from 'src/components/Globals/Breadcrumb'

Vue.component('bkitlogo', Bkitlogo)
Vue.component('formateddate', Formateddate)
Vue.component('formatedsize', Formatedsize)
Vue.component('breadcrumb', Breadcrumb)

import Vuelidate from 'vuelidate'
Vue.use(Vuelidate)

import interceptorsSetup from 'src/helpers/interceptors'

interceptorsSetup()

export default {
  name: 'App'
}
</script>

<style>
</style>
