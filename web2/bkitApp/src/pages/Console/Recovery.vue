<template>
  <div class="recovery">
    <el-dialog title="Recovery" v-model="isVisible"
      class="dialog">
      <div>{{origin}} => {{dst}}/{{resource.entry}}</div>
      <div v-if="isOriginalLocation">
        Are you really sure that you want restore to the original location?
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button-group>
          <el-button @click="isVisible = false">
            Cancel
          </el-button>
          <el-button @click="selectLocation" type="primary">
            Change
          </el-button>
          <el-button v-if="isSameComputer" type="primary" @click="recovery">
            Restore
          </el-button>
          <el-button v-else type="primary" @click="recovery">
            Import
          </el-button>
        </el-button-group>
      </span>
    </el-dialog>
    <section :class="{show:visible}">
      <div class="stdout">{{stdout}}</div>
      <div class="stderr">{{stderr}}</div>
    </section>
  </div>
</template>

<script>

import path from 'path'
const {spawn} = require('child_process')
const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
console.log('Recovery..............')
import {myMixin} from 'src/mixins'

export default {
  data () {
    return {
      isVisible: false,
      drive: '',
      stdout: '',
      stderr: '',
      dst: '',
      src: '',
      computer: this.$store.getters.computer || {}
    }
  },
  computed: {
    myid () {
      return this.computer.id
    },
    computerId () {
      return this.resource.computer
    },
    isOriginalLocation () {
      return this.myid === this.computerId && this.src === this.dst
    },
    isSameComputer () {
      return this.myid === this.computerId
    },
    isOriginalDiskPresent () {
      return this.src !== ''
    },
    origin () {
      const orig = `${this.resource.path}/${this.resource.entry}`
      if (this.isOriginalDiskPresent) {
        return `Backup of "${orig}"`
      } else if (this.isSameComputer) {
        return `Import "${orig}" from a older drive in backup`
      } else {
        const names = this.resource.computer.split('.')
        names.pop()
        const comp = names.pop()
        return `Import "${orig}" from computer ${comp} in backup`
      }
    }
  },
  props: ['resource', 'visible'],
  components: {
  },
  /*  created () {
    process.platform === 'win32' && exec('NET SESSION', (err) => {
      if (err) {
        this.$notify.warning({
          title: 'Missing privilegies',
          message: 'You should run as Administrator in order to have full access',
          customClass: 'message warning',
          duration: 0
        })
      }
    })
  }, */
  mounted () {
    let resource = this.resource || {}
    console.log('Recovery', resource)
    let [, volID] = (resource.drive || '').split(/\./)
    let cwd = process.cwd()
    console.log('cwd=', cwd)
    console.log('__dirname=', __dirname)
    console.log('__filename=', __filename)
    let remote = require('electron').remote
    let app = remote.app
    let basepath = app.getAppPath()
    console.log('basepath = ', basepath)
    const fd = spawn(BASH, ['./findDrive.sh', volID], {cwd: '../..'})
    fd.stdout.on('data', (data) => {
      console.log('data')
      const root = `${data}`.replace(/\r?\n.*$/, '')
      this.src = path.resolve(root, resource.path)
      this.isVisible = true
      this.dst = this.src
    })
    fd.stderr.on('data', (msg) => {
      console.error('Error:', `${msg}`)
      this.catch(`${msg}`)
    }) 

    fd.on('close', (code) => {
      code = 0 | code
      console.log('close')
      if (code === 1) { // In case of volume wasn't found
        this.src = ''
        this.$notify.info({
          title: 'Volume not found on this computer',
          message: 'You can still recovery it but you must choose an alternative location',
          duration: 1000,
          onClose: () => {
            const folder = this.selectDestination()
            if (folder) {
              this.isVisible = true
              this.dst = folder
            }
          }
        })
      }
    })
  },
  mixins: [myMixin],
  methods: {
    selectDestination () {
      const {dialog} = require('electron').remote
      const [folder] = dialog.showOpenDialog({
        properties: ['openDirectory'],
        title: 'Destination dolder',
        message: 'Choose an location where to restore'
      }) || []
      return folder
    },
    selectLocation () {
      this.dst = this.selectDestination() || this.dst
    },
    recovery () {
      this.isVisible = false
      const entry = this.resource.entry
      const {dst, src} = this
      const cmd = ['./restore.sh', `--dst=${dst}`]
      if (src && src !== dst) {
        cmd.push(`--link-dest=${src}`)
      }
      if (!this.isSameComputer) {
        cmd.push('--no-owner')
      }
      cmd.push(this.resource.url)

      const fd = spawn(BASH, cmd, {cwd: '..'})

      const now = (new Date()).toString()
      this.stdout = `\n------ Start restore ${entry} at ${now}------\n`
      const errhead = `\n------ Start restore ${entry} at ${now} ------\n`
      fd.stdout.on('data', (data) => {
        this.stdout += `${data}`
        this.stdout = this.stdout.substr(-10000)
      })

      let errdata = ''
      fd.stderr.on('data', (data) => {
        errdata += `${data}`
        this.stderr = errhead + errdata.substr(-10000)
      })

      fd.on('close', (code) => {
        code = 0 | code
        if (code === 0) {
          this.$notify.success({
            title: 'Good news',
            message: `${entry} was successfully restored to ${dst}`
          })
        } else {
          this.$notify.warning({
            title: 'Please verify logs',
            message: "Something didn't go as expected"
          })
        }
        const now = (new Date()).toString()
        this.stdout += `\n------ Finish at ${now} ------\n`
        if (errdata !== '') {
          this.stderr += `\n------ Finish at ${now} ------\n`
        }
      })
    }
  }
}

</script>

<style scoped lang="scss">
  .recovery {
    section {
      transition: max-height 1s cubic-bezier(0,1,0,1);
      overflow-y: hidden;
      max-height: 0;
      &.show{
        max-height: 100000vh;
        transition-timing-function: cubic-bezier(1,0,1,0);
        overflow-y: visible;
      }
      *{
        overflow-y: visible;
      }
      .stdout, .stderr {
        font-family: monospace;
        margin-bottom: 1px;
        white-space: pre-line;
        background-color: white;
        color: darkgreen;
        padding: 2px;
        padding-left:1em;
      }
      .stderr{
        color: darkred;
      }
    }
  }
</style>
