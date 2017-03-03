<template>
  <div class="init">
    <bkitlogo></bkitlogo>
    <h2>Set backup server to {{address}}</h2>
    <section>
      <div class="stdout">
        {{stdout}}
      </div>
      <div class="stderr">
        {{stderr}}
      </div>
    </section>
    <el-button-group>
      <el-button type="primary" @click="goback">Return</el-button>
      <el-button type="primary" @click="init">Init</el-button>
    </el-button-group>
  </div>
</template>

<script>
const path = require('path')
const {spawn} = require('child_process')
const platform = require('os').platform()
const parentDir = path.resolve(process.cwd(), '..')
const BASH = platform === 'win32' ? `${parentDir}\\bash.bat` : 'bash'

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
    this.isVisible = true
  },
  methods: {
    goback () {
      this.$router.back()
    },
    init () {
      this.isVisible = false
      const fd = spawn(BASH, ['./init.sh'], {cwd: parentDir})
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
            title: 'Init done',
            message: 'Successfully'
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
    display:flex;
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
        color: darkgreen;
        padding: 2px;
      }
      .stderr{
        color: darkred;
      }
    }
  }
</style>

