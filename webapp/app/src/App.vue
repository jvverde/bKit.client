<style lang="scss">

  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
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

  .message {
    border-radius: 5px;
    font-size: 10px;
    * {
      white-space: pre-line;
    }
  }
  .message.warning {
    background-color: #F5F5DC; /* https://en.wikipedia.org/wiki/Category:Shades_of_yellow */
  }
  .message.error {
    background-color: #F9CCCA; /* https://en.wikipedia.org/wiki/Shades_of_pink */
  }
  .alert {
    color: #DE3163;
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
  const {spawnSync} = require('child_process')
  const path = require('path')
  const parentDir = path.resolve(process.cwd(), '..')
  const BASH = require('os').platform() === 'win32' ? 'bash.bat' : 'bash'

  export default {
    store,
    created: function () {
      ipcRenderer.send('clear', '')
      try {
        let addr = this.$electron.remote.getGlobal('settings').server.address
        if (addr == '') {
          console.log('Find server')
          const fd = spawnSync(BASH, ['./getBackupAddr.sh'], {cwd: '..'})
          fd.stdout.on('data', (data) => {
            addr = (`${data}` || '').replace(/(\n|\r)+$/, '')
          })
        }
        this.$store.dispatch('setServerAddress', addr)
        this.$store.dispatch('setServerPort', this.$electron.remote.getGlobal('settings').server.port)
      } catch (e) {
        console.error(e)
      }
      try {
        const fd = spawnSync(BASH, ['./getComputerName.sh'], {cwd: '..'})
        fd.stdout.on('data', (data) => {
          const name = (`${data}` || '').replace(/(\n|\r)+$/, '')
          store.dispatch('setComputerName', name)
        })
        fd.stderr.on('data', (msg) => {
          this.$notify.error({
            title: 'Error in App doing ./getComputerName',
            message: `${BASH}:${msg}`,
            customClass: 'message error'
          })
        })
      } catch (e) {
        console.error(e)
      }
    },
    methods: {
      debug () {
        console.log('open debug window')
        ipcRenderer.send('debug', 'on')
      }
    },
    destroy () {
      // console.log('Destroy App')
      // ipcRenderer.send('clear', '')
      // ipcRenderer.removeAllListeners()
    }
  }
</script>
