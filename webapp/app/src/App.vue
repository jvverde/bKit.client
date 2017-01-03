<style lang="scss">

  * {
    margin: 0;
    padding: 0;
  }

  html,
  body { 
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

<template>
  <router-view></router-view>
</template>

<script>
  import store from 'src/vuex/store'

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
    }
  }
</script>
