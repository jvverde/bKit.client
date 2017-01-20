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
    <li>
      <recovery :resource="resource"></recovery>
    </li>
  </ul>
</template>

<script>
import Recovery from './Dialogs/Recovery'
const {ipcRenderer, shell} = require('electron')
const net = require('net')
const path = require('path')
const fs = require('fs')
let server = null
export default {
  name: 'console',
  data () {
    return {
      resource: null,
      logs: [],
      downloads: []
    }
  },
  components: {
    Recovery,
    ipcRenderer,
    shell
  },
  created () {
    ipcRenderer.on('console', (event, arg) => {
      console.log('Received', arg)
      if (arg instanceof Object && arg.type === 'download') {
        this.downloads.push(arg)
      }
      if (arg.type === 'download' && arg.mimetype === 'application/bkit') {
        try {
          let file = fs.readFileSync(arg.fullpath)
          this.resource = JSON.parse(file)
          this.resource.downloadLocation = arg.fullpath
        } catch (err) {
          this.$notify.error({
            title: `File:${arg.filename}`,
            message: `Error: ${err}`
          })
        }
      } else if (arg.type === 'download') {
        this.$notify.info({
          title: arg.filename,
          message: 'Download completed'
        })
      }
    })
    ipcRenderer.send('register', 'console')
    server = net.createServer(function (stream) {
      console.log('client connected')
      stream.on('data', function (c) {
        console.log('data from pipe:', c.toString())
        stream.end('Hello\r\n')
      })
      stream.on('end', function () {
        console.log('end')
      // server.close()
      })
    })
    .listen(9876, 'localhost', () => {
      console.log('server bound')
    })
  },
  methods: {
    openFile (index) {
      // shell.openItem(this.downloads[index].fullpath)
    },
    showFolder (index) {
      shell.showItemInFolder(this.downloads[index].fullpath)
    },
    run (index) {
      console.log(path.dirname(process.mainModule.filename))
      console.log(path.dirname(__dirname))
      const spawn = require('child_process').spawn
      const ls = spawn('sudo.bat', ['./recovery.sh', this.downloads[index].fullpath], {cwd: '..'})

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
    server.close()
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
