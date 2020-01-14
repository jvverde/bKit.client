<template>
  <q-page class="flex flex-center">
    here is home
    <downloads></downloads>
  </q-page>
</template>

<style>
</style>

<script>
const {ipcRenderer} = require('electron')
import Downloads from '@/Console/Downloads'
export default {
  name: 'PageIndex',
  components: {
    Downloads
  },
  created () {
    console.log('Home')
    ipcRenderer.send('openUrl', 'http://localhost:8080/remote/computers')
  }
}
</script>
