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
      <span slot="footer" class="dialog-footer">
        <el-button-group>
          <el-button @click="isVisible = false">Cancel</el-button>
          <el-button type="success" @click="recovery">Continue</el-button>
        </el-button-group>
      </span>
    </el-dialog>
    <div class="stdout">
      {{stdout}}
    </div>
    <div class="stderr">
      {{stderr}}
    </div>
  </div>
</template>

<script>
const path = require('path')
const {spawn, exec} = require('child_process')
export default {
  data () {
    return {
      isVisible: false,
      drive: '',
      stdout: '',
      stderr: '',
      location: undefined,
      computerName: ''
    }
  },
  props: ['resource'],
  components: {
  },
  created () {
    exec('NET SESSION', (err) => {
      if (err) {
        this.$notify.warning({
          title: 'Missing privilegies',
          message: 'You should run as Administrator',
          customClass: 'message warning',
          duration: 0
        })
      }
    })
    const fd = spawn('bash.bat', ['./getComputerName.sh', volID], {cwd: '..'})
    fd.stdout.on('data', (data) => {
      this.computerName = `${data}`
    })
    fd.stderr.on('data', (msg) => {
      this.$notify.error({
        title: 'Error',
        message: `${msg}`,
        customClass: 'message error'
      })
    })
  },
  watch: {
    resource: function (resource) {
      resource = resource || {}
      let [letter, volID] = (resource.drive || '').split(/\./)
      const fd = spawn('bash.bat', ['./findDrive.sh', volID], {cwd: '..'})

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
            duration: 1000,
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
    }
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
      const fd = spawn('bash.bat', ['./recovery.sh', this.resource.downloadLocation, dst], {cwd: '..'})
      const now = (new Date()).toString()
      this.stdout += `\n-------- Start recovery ${this.path} at ${now} --------\n`
      this.stderr += `\n-------- Start recovery ${this.path} at ${now} --------\n`
      fd.stdout.on('data', (data) => {
        this.stdout += `${data}`
      })

      fd.stderr.on('data', (data) => {
        this.stderr += `${data}`
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
  .stdout, .stderr {
    white-space: pre-line;
    background-color: black;
    color: white;
    padding: 2px;
    padding-left:1em;
    font-size: 10px;
  }
  .stderr{
    color: #800;
  }
</style>
<style lang="scss">
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
</style>

