<template>
  <div class="init">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <ul class="breadcrumb">
        <li>
          <span>
            <router-link to="/" class="icon is-small">
              <i class="fa fa-home">Home</i>
            </router-link>
          </span>
        </li>
      </ul>
      <h2>Backup Server</h2>
    </header>
    <h2>Set {{address}} as the Backup Server</h2>
    <el-button-group class="buttons">
      <el-button type="primary" @click="goback" icon="arrow-left">Return</el-button>
      <el-button type="primary" @click="init">Set
        <i class="fa fa-cloud-download" aria-hidden="true"></i>
      </el-button>
    </el-button-group>
    <section class="output" v-if="output">
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
const {spawn} = require('child_process')
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
  },
  computed: {
    output () {
      return this.stdout !== '' || this.stderr !== ''
    }
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
      let stderr = `\n-------- Start init script at ${now} --------\n`
      fd.stdout.on('data', (data) => {
        this.stdout += `${data}`
        this.stdout = this.stdout.substr(-10000)
      })

      fd.stderr.on('data', (data) => {
        this.stderr = stderr + `${data}`
        this.stderr = this.stderr.substr(-10000)
      })

      fd.on('close', (code) => {
        code = 0 | code
        if (code === 0) {
          this.$notify.success({
            title: 'Backup Server',
            message: 'Set successfully'
          })
          try { // ok, update (last) server port and address
            this.$electron.remote.getGlobal('settings').server
              .address = this.$store.getters.address
            this.$electron.remote.getGlobal('settings').server
              .port = this.$store.getters.port
          } catch (e) {
            console.error('Setting globals address', e)
          }
        } else {
          this.$notify.warning({
            title: 'Please verify logs',
            message: "Something didn't go as expected"
          })
        }
        const now = (new Date()).toString()
        this.stdout += `\n-------- Finish at ${now} --------\n`
        if (this.stderr !== '') {
          this.stderr += `\n-------- Finish at ${now} --------\n`
        }
      })
    }
  }
}

</script>

<style scoped lang="scss">
  @import "../breadcrumb.scss";
  .init{
    display:flex;
    flex-direction: column;
    align-items: center;
    header.top{
      flex-shrink:0;
      width: 100%;
      align-self:flex-start;
      .logo{
        float:left;
      }
    }
    >*{
      flex-shrink: 0;
    }
    section.output {
      overflow: auto;
      flex-shrink: 1;
      margin: 2px;
      margin-top: 1em;
      flex-grow:1;
      padding: .5em;
      text-align: left;
      font-family: monospace;
      white-space: pre-line;
      background-color: silver;
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

