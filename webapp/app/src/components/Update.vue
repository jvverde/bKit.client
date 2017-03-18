<template>
  <div class="update">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <ul class="breadcrumb">
        <li>
          <span>
           <router-link to="/" class="icon is-small"><i class="fa fa-home">Home</i></router-link>
          </span>
        </li>
      </ul>
    </header>
    <section>
      <h1>Client Update</h1>
      <el-button type="primary" @click.stop="update">Update</el-button>
    </section>
    <section class="console" v-if="stdout || stderr">
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
    name: 'update',
    data () {
      return {
        stdout: '',
        stderr: ''
      }
    },
    methods: {
      update () {
        try {
          const fd = spawn(BASH, ['./update.sh'], {cwd: '..'})
          const now = (new Date()).toString()
          this.stdout += `\n-------- Start update script at ${now} --------\n`
          this.stderr += `\n-------- Start update script at ${now} --------\n`
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
                title: 'Done',
                message: 'Client successfully updated'
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
        } catch (e) {
          this.loading = false
          console.error(e)
        }
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../breadcrumb.scss";
  .update{
    display: flex;
    flex-direction: column;
    .top {
      .logo{
        float: left;
      }
    }
    section.console {
      overflow-y: auto;
      flex-shrink: 1;
      margin: 1px;
      .stdout, .stderr {
        padding: 2px;
        margin: 1px; 
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
  }
</style>
