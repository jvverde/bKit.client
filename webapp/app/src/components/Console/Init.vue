<template>
  <div class="init">
    <bkitlogo></bkitlogo>
    <h2>Set {{address}} as the Backup Server</h2>
    <el-button-group class="buttons">
      <el-button type="primary" @click="goback" icon="arrow-left">Return</el-button>
      <el-button type="primary" @click="init">Set <i class="el-icon-upload2"></el-button>
    </el-button-group>
    <section>
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
const {spawn} = require('child_process')
const parentDir = path.resolve(process.cwd(), '..')
const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'

export default {
  data () {
    return {
      stdout: '',
      stderr: '',
      address: this.$store.getters.address
    }
  },
  mounted () {
    console.log('init console')
  },
  methods: {
    goback () {
      this.$router.back()
    },
    init () {
      this.isVisible = false
      const fd = spawn(BASH, ['./init.sh', this.address], {cwd: '..'})
      const now = (new Date()).toString()
      this.stdout += `\n-------- Start init script at ${now} --------\n`
      this.stderr += `\n-------- Start init script at ${now} --------\n`
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
            title: 'Backup Server',
            message: 'Set successfully'
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
  .init {
    display: flex;
    flex-direction: column;
    align-items: center;
    >*{
      flex-shrink: 0;
    }
    section {
      overflow-y: auto;
      flex-shrink: 1;
      margin-top: .5em;
      margin-bottom: .5em;
      padding: 1px;
      .stdout, .stderr {
        text-align: left;
        font-family: monospace;
        white-space: pre-line;
        background-color: silver;
      }
      .stdout {
        color: darkgreen;
      }
      .stderr{
        color: darkred;
      }
    }
    .buttons {
      margin: .5em;
    }
  }
</style>

