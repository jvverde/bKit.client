<template>
  <div class="server">
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
      <h1>Server Location</h1>
      <table>
        <tr>
          <td>Address:</td>
          <td><input v-model="address" placeholder="Server IP or Name address"></td>
        </tr>
        <tr>
          <td>Port:</td>
          <td><input v-model="port" type="numeric" min="80" max="65535" placeholder="Port number"></td>
        </tr>
      </table>
      <el-button-group class="buttons">
        <el-button type="primary" @click.stop="goback" icon="arrow-left">Return</el-button>
        <el-button type="primary" @click.stop="go"
          :disabled="!isValid">Go <i class="el-icon-arrow-right el-icon-right"></i></el-button>
      </el-button-group>
    </section>
  </div>
</template>

<script>
export default {
  name: 'server',
  computed: {
    address: {
      get () {
        return this.$store.state.server.address
      },
      set (value) {
        this.$store.dispatch('setServerAddress', value)
      }
    },
    port: {
      get () {
        return this.$store.state.server.port
      },
      set (value) {
        this.$store.dispatch('setServerPort', value)
      }
    },
    isValid () {
      return this.$store.state.server.address !== '' && this.$store.state.server.port > 0 && this.$store.state.server.port < 65536
    }
  },
  methods: {
    goback () {
      this.$router.back()
    },
    go () {
      this.$router.push({ path: '/computers' })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../breadcrumb.scss";
  .server{
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
      a {
        text-decoration: none;
      }
      a:hover {
        color: rgb(40, 56, 76);
      }
      .set{
        position: absolute;
        bottom: 1em;
        right: 1em;
      }
      .buttons{
        align-self:flex-end;
      }
    } 
  }
</style>
