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
    font-family: Helvetica, Verdana, Arial, sans-serif;
    justify-content: center;
    text-align: center;
  }
  a {
    text-decoration: none;
  }
</style>

<style lang="scss" scoped>
  .main {
    height:100%;
    width: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
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
  const {spawn} = require('child_process')
  const BASH = require('os').platform() === 'win32' ? 'bash.bat' : 'bash'

  export default {
    store,
    created: function () {
      const fd = spawn(BASH, ['./getComputerName.sh'], {cwd: '..'})
      fd.stdout.on('data', (data) => {
        const name = (`${data}` || '').replace(/(\n|\r)+$/, '')
        store.dispatch('setComputerName', name)
      })
      fd.stderr.on('data', (msg) => {
        this.$notify.error({
          title: 'Error',
          message: `${msg}`,
          customClass: 'message error'
        })
      })
    },
    methods: {
      debug () {
        console.log('open debug window')
        ipcRenderer.send('debug', 'on')
      }
    }
  }
</script>
