<style lang="scss">

  * {
    margin: 0;
    padding: 0;
  }

  html,
  body{
    height:100%;
    width: 100%;
    overflow: hidden;
  }

  body {
    font-family: Helvetica, sans-serif;
    justify-content: center;
    text-align: center;
  }
</style>

<style lang="scss" scoped>
  .main {
    height:100%;
    width: 100%;
    overflow: hidden;
  }
  .opendebug {
    font-size: 8pt;
    position: absolute;
    bottom: 0;
    left: 0;
    z-index: 10;
    opacity: 0;
    &:hover{
      cursor: help;
    }
  }
</style>

<template>
  <div class="main">
    <span @click="debug" class="opendebug">.</span>
    <router-view></router-view>
  </div>
</template>

<script>
  import store from 'src/vuex/store'
  const {ipcRenderer} = require('electron')

  export default {
    store,
    created: function () {
      if ('$electron' in this) {
        let addr = this.$electron.remote.getGlobal('server').address
        let port = this.$electron.remote.getGlobal('server').port
        if (typeof addr === 'string' && addr.length > 0) {
          store.dispatch('setServerAddress', addr)
        }
        typeof port === 'string' && (port = 0 | port)
        if (typeof port === 'number' && port > 0) {
          store.dispatch('setServerPort', port)
        }
      }
    },
    methods: {
      debug () {
        console.log('open debug window')
        ipcRenderer.send('debug', 'on')
      }
    }
  }
</script>
