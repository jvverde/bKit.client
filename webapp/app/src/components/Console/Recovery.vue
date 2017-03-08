<template>
  <div class="recovery">
    <el-dialog title="Recovery" v-model="isVisible" size="small" class="dialog">
      <h3>
        {{path}}
        <span v-if="location">
          =>
          <a href="" @click.prevent="selectLocation">{{location}}</a>
        </span>
      </h3>
      <div v-if="myid !== computerId">
        <div class="alert">Please notice: You are in a different computer</div>
        <div v-if="location === path">Are you really sure that you want to import and overwrite you local data?</div>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button-group>
          <el-button @click="isVisible = false">Cancel</el-button>
          <el-button v-if="myid !== computerId" type="warning" @click="recovery">Import</el-button>
          <el-button v-else type="primary" @click="recovery">Continue</el-button>
        </el-button-group>
      </span>
    </el-dialog>
    <section :class="{show:show}">
      <div class="stdout">
        {{stdout}}
      </div>
      <div class="stderr">
        {{stderr}}
      </div>
    </section>
  </div>
</template>

<script>
const path = require('path')
const {spawn, exec} = require('child_process')
const os = require('os')
const parentDir = path.resolve(process.cwd(), '..')
const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'

export default {
  data () {
    return {
      isVisible: false,
      drive: '',
      stdout: '',
      stderr: '',
      location: undefined,
      myself: this.$store.getters.computer || {}
    }
  },
  computed: {
    myid () {
      return this.myself.id
    },
    computerId () {
      return this.resource.computer
    }
  },
  props: ['resource', 'show'],
  components: {
  },
  created () {
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
  },
  mounted () {
    console.log('recovery mounted')
    let resource = this.resource || {}
    let [letter, volID] = (resource.drive || '').split(/\./)
    const fd = spawn(BASH, ['./findDrive.sh', volID], {cwd: '..'})

    fd.stdout.on('data', (data) => {
      let drive = `${data}`.replace(/\r?\n.*$/, '')
      this.path = path.resolve(drive, resource.path, resource.entry)
      this.isVisible = true
      this.location = this.path
    })

    fd.stderr.on('data', (msg) => {
      this.$notify.error({
        title: 'Error',
        message: `${msg}`,
        customClass: 'message error'
      })
    })

    fd.on('close', (code) => {
      code = 0 | code
      if (code === 2) { // In case of volume wasn't found
        this.$notify.info({
          title: 'Volume not found on this computer',
          message: 'You can still recovery it but you must choose an alternate location',
          duration: 2000,
          onClose: () => {
            const folder = this.selectDestination()
            if (folder) {
              this.isVisible = true
              this.path = path.resolve(`${letter}:/`, resource.path, resource.entry)
              this.location = folder
            }
          }
        })
      }
    })
  },
  methods: {
    selectDestination () {
      const {dialog} = this.$electron.remote
      const [folder] = dialog.showOpenDialog({properties: ['openDirectory']}) || []
      return folder
    },
    selectLocation () {
      // this.isVisible = false
      this.location = this.selectDestination() || this.location
      // this.isVisible = true
      console.log('Location:', this.location)
    },
    recovery () {
      this.isVisible = false
      const dst = this.location === this.path ? '' : this.location || ''
      const fd = spawn(BASH, ['./recovery.sh', '-y', '-f', this.resource.downloadLocation, dst], {cwd: '..'})
      const now = (new Date()).toString()
      this.stdout += `\n-------- Start recovery ${this.path} at ${now} --------\n`
      this.stderr += `\n-------- Start recovery ${this.path} at ${now} --------\n`
      fd.stdout.on('data', (data) => {
        this.stdout += `${data}`
        this.stdout = this.stdout.substr(-10000)
      })

      fd.stderr.on('data', (data) => {
        this.stderr += `${data}`
        this.stderr = this.stderr.substr(-10000)
      })

      fd.on('close', (code) => {
        code = 0 | code
        if (code === 0) {
          this.$notify.success({
            title: 'Good news',
            message: `${this.path} was successfully recovered`
          })
        } else {
          this.$notify.warning({
            title: 'Please verify logs',
            message: "Something didn't go as expected"
          })
        }
        const now = (new Date()).toString()
        this.stdout += `\n-------- Finish at ${now} --------\n`
        this.stderr += `\n-------- Finish at ${now} --------\n`
      })
    }
  }
}

</script>

<style scoped lang="scss">
  .recovery {
    section {
      transition: max-height 2s cubic-bezier(0,1,0,1);
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


