<template>
  <div class="smtp">
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
    </header>
    <section>
      <h1>Notifications</h1>
      <div class="form">
      <table>
        <tr>
          <td>SMTP Server Address:</td>
          <td>
            <input v-model="server" placeholder="SMTP Server IP or Name address">
          </td>
          <td>
            <i v-if="isServerOk === null" class="fa fa-cog fa-spin fa-fw" aria-hidden="true"></i>
            <i v-if="isServerOk === false" class="fa fa-exclamation-triangle alert" aria-hidden="true"></i>
            <i v-if="isServerOk === true" class="fa fa-check ok" aria-hidden="true"></i>
          </td>
        </tr>
        <tr v-for="(address, index) in addresses">
          <td :rowspan="addresses.length" v-if="index === 0">Send Notifications To:</td>
          <td>
            <input type="email" v-model="addresses[index]"
              v-validate="'required|email'" data-vv-delay="1000" :data-vv-name="'email'+index"
              placeholder="Destinations address">
            <i class="fa fa-exclamation-triangle alert error" v-show="errors.has('email'+index)"
              :title="errors.first('email'+index)"></i>
          </td>
          <td v-if="index > 0">
            <el-button type="danger" :plain="true" size="mini" icon="minus" @click.stop="addresses.splice(index,1)"></el-button>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <el-button type="success" :plain="true" size="mini" icon="plus" @click.stop="addresses.push('')"></el-button>
          </td>
        </tr>
      </table>
      </div>
      <el-button-group class="buttons">
        <el-button type="primary" @click.stop="goback" icon="arrow-left">Return</el-button>
        <el-button type="primary" @click.stop="apply" :disabled="isDisable">
          Save
          <i class="fa fa-floppy-o"></i>
        </el-button>
      </el-button-group>
    </section>
  </div>
</template>

<script>
const {spawn} = require('child_process')
const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
const fs = require('fs')
const path = require('path')
const readline = require('readline')
const smtpfile = path.resolve(process.cwd(), '..', 'conf', 'smtp.init')
const validServerAddr = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

export default {
  name: 'server',
  data () {
    return {
      init: {},
      addresses: [''],
      child: null
    }
  },
  computed: {
    server: {
      get () {
        return this.init.SERVER || ''
      },
      set (v) {
        this.init.SERVER = v
        this.check()
      }
    },
    isDisable () {
      return this.fields.failed() || this.connectError !== false
    },
    isValidName () {
      return this.server.match(validServerAddr) !== null
    }
  },
  asyncComputed: {
    isServerOk () {
      return new Promise(resolve => {
        console.log('ckeck', this.server, this.isValidName)
        if (!this.isValidName) return resolve(undefined)
        console.log('go-check')
        // if (this.child) this.child.kill('SIGKILL')
        const fd = this.child = spawn(BASH, ['./check-smtp.sh', this.server], {cwd: '..'})
        let error = ''
        fd.stderr.on('data', (data) => {
          error = `${data}`
        })
        fd.on('close', (code, signal) => {
          console.log('signal=', signal)
          code = 0 | code
          if (code === 1) {
            this.$notify.error({
              title: 'SMTP Server connect error',
              message: error
            })
            resolve(false)
          } else {
            resolve(true)
          }
          this.child = null
        })
      })
    }
  },
  created () {
    if (fs.existsSync(smtpfile)) {
      readline.createInterface({
        input: require('fs').createReadStream(smtpfile)
      }).on('line', (line) => {
        const [k, v] = line.split(/=/)
        this.$nextTick(() => {
          if (k === 'TO') {
            this.addresses = v.split(',')
          }
          this.init = Object.assign({}, this.init, {[k]: v})
        })
      })
    }
  },
  methods: {
    goback () {
      this.$router.back()
    },
    apply () {

    },
    check () {
      console.log('ckeck', this.server)
      this.connectError = undefined
      const fd = spawn(BASH, ['./check-smtp.sh', this.server], {cwd: '..'})
      let error = ''
      fd.stderr.on('data', (data) => {
        error = `${data}`
      })
      fd.on('close', (code) => {
        code = 0 | code
        if (code === 1) {
          this.$notify.error({
            title: 'SMTP Server connect error',
            message: error
          })
          this.connectError = true
        } else {
          this.connectError = false
        }
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../breadcrumb.scss";
  .smtp{
    display:flex;
    flex-direction: column;
    flex-grow: 1;
    header.top{
      flex-shrink:0;
      .logo{
        float:left;
      }
    }
    section{
      display:flex;
      flex-grow: 1;
      flex-direction: column;
      align-self: center;
      h1, h2 {
        font-weight: normal;
      }
      .form{
        flex-grow: 1;
        overflow-y: auto;
      }
      .buttons{
        align-self:center;
      }
      td{
        position: relative;
        .error {
          position:absolute;
          right: 3px;
          bottom: 3px;
        }
      }
      td:first-child{
        text-align: right;
      }
    }
  }
</style>
