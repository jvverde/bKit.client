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
      <table>
        <tr>
          <td>Server Address:</td>
          <td><input v-model="server" placeholder="SMTP Server IP or Name address"></td>
        </tr>
        <tr v-for="(address, index) in addresses">
          <td>To:</td>
          <td><input type="email" v-model="addresses[index]" placeholder="Destinations address"></td>
        </tr>
      </table>
      <el-button-group class="buttons">
        <el-button type="primary" @click.stop="goback" icon="arrow-left">Return</el-button>
        <el-button type="primary" @click.stop="apply"
          :disabled="!isValid">Apply<i class="el-icon-arrow-right el-icon-right"></i></el-button>
      </el-button-group>
    </section>
  </div>
</template>

<script>
const fs = require('fs')
const path = require('path')
const readline = require('readline')
const smtpfile = path.resolve(process.cwd(), '..', 'conf', 'smtp.init')

export default {
  name: 'server',
  data () {
    return {
      init: {},
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
    }
  },
  created () {
    if (fs.existsSync(smtpfile)) {
      readline.createInterface({
        input: require('fs').createReadStream(smtpfile)
      }).on('line', (line) => {
        console.log('Line from file:', line)
        const [k, v] = line.split(/=/)
        console.log(k)
        console.log(v)
        this.$nextTick(() => {
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
    header.top{
      flex-shrink:0;
      .logo{
        float:left;
      }
    }
    section{
      display:flex;
      flex-direction: column;
      align-self: center;
      h1, h2 {
        font-weight: normal;
      }
      .buttons{
        align-self:flex-end;
      }
    }
  }
</style>
