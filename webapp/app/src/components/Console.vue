<template>
  <ul class="console">
    <li v-for="(download,index) in downloads">
      <div>{{download.filename}}</div>
      <div>
        <span class="icon is-small" @click.prevent="openFile(index)">
          <i class="fa fa-eye"></i>
        </span>
         <span class="icon is-small" @click.prevent="showFolder(index)">
          <i class="fa fa-folder-o"></i>
        </span>
        <span class="icon is-small" @click.prevent="run(index)">
          <i class="fa fa-cogs"></i>
        </span>
      </div>
    </li>
  </ul>
</template>

<script>
const {ipcRenderer, shell} = require('electron')

export default {
  name: 'console',
  data () {
    return {
      logs: [],
      listener: null,
      downloads: []
    }
  },
  components: {
    ipcRenderer,
    shell
  },
  created () {
    ipcRenderer.on('console', (event, arg) => {
      console.log('Received', arg)
      if (arg instanceof Object && arg.type === 'download') {
        this.downloads.push(arg)
      }
    })
    ipcRenderer.send('register', 'console')
  },

  methods: {
    openFile (index) {
      shell.openItem(this.downloads[index].fullpath)
    },
    showFolder (index) {
      shell.showItemInFolder(this.downloads[index].fullpath)
    },
    run (index) {
      const spawn = require('child_process').spawn
      const ls = spawn('bash.bat', ['recovery.sh', this.downloads[index].fullpath], {cwd: '..'})

      ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`)
        this.logs = `${data}`.split(/\n/)
      })

      ls.stderr.on('data', (data) => {
        console.log(`stderr: ${data}`)
      })

      ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`)
      })
    }
  },
  destroyed () {
    console.log('destroy')
    // ipcRenderer.removeAllListeners('console')
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .console{
    max-height: 10em;
    overflow: auto;
    width: 100%;
    text-align: left;
    margin: 2px;
    padding: 2px;
    background-color: #EEE;
    li{
      display:flex;
      flex-wrap:nowrap;
      justify-content:space-between;
    }
  }
</style>
