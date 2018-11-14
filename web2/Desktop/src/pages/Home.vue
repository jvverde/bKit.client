<template>
  <q-page class="flex flex-center">
    here is home
  </q-page>
</template>

<style>
</style>

<script>
const {ipcRenderer} = require('electron')
export default {
  name: 'PageIndex',
  created () {
    console.log('Home')
    ipcRenderer.send('openUrl', 'http://localhost:8080/remote/computers')
  }
}
</script>
