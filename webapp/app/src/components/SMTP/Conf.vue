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
              placeholder="Destinations address">
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
const IPAddrRE = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

const HostnameRE = /^(([a-z]|[a-z][a-z0-9\-]*[a-z0-9])\.)*([a-z]|[a-z][a-z0-9\-]*[a-z0-9])$/i
const validServerAddr = new RegExp(IPAddrRE.source + '|' + HostnameRE.source)
const validEmail = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i

export default {
  name: 'SmtpConf',
  data () {
    return {
      init: {
        SERVER: ''
      },
      addresses: ['']
    }
  },
  computed: {
    server: {
      get () {
        return this.init.SERVER
      },
      set (v) {
        this.init.SERVER = v
      }
    },
    isOk () {
      return this.isValidName && this.areValidAddress
    },
    isDisable () {
      return this.isOk === false
    },
    isValidName () {
      return this.server.match(validServerAddr) !== null
    },
    areValidAddress () {
      return this.addresses.every(e => {
        return e.match(validEmail) !== null
      })
    }
  },
  asyncComputed: {
    isServerOk () {
      return new Promise(resolve => this.checkSMTP(resolve))
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
    checkSMTP (resolve) {
      if (!this.isValidName) return resolve(undefined)
      if (this.isChecking) {
        console.log('wait')
        this.nextResolver = resolve
        return
      }
      this.isChecking = true
      console.log('go-check', this.server)
      this.lastAddr = this.server
      const fd = spawn(BASH, ['./check-smtp.sh', this.server], {cwd: '..'})
      let error = ''
      fd.stderr.on('data', (data) => {
        error = `${data}`
      })
      fd.on('close', (code) => {
        this.isChecking = false
        if (this.lastAddr !== this.server && this.nextResolver instanceof Function) {
          console.log('Go check again')
          this.checkSMTP(this.nextResolver)
        }
        if (code === 1) {
          console.log('nok', error)
          resolve(false)
        } else {
          console.log('ok')
          resolve(true)
        }
        console.log('ckecked')
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../../breadcrumb.scss";
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
        flex-grow: .1;
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
