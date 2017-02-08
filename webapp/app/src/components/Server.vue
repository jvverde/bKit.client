<template>
  <div class="server">
    <bkitlogo></bkitlogo>
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
    <router-link :to="{name: 'Computers-page'}" v-if="isValid">
      <el-button type="success">Go</el-button>
    </router-link>
    <el-button disabled v-else>Go</el-button>
  </div>
</template>

<script>
export default {
  name: 'server',
  mounted () {
    try {
      this.$store.dispatch('setServerAddress', this.$electron.remote.getGlobal('settings').server.address)
      this.$store.dispatch('setServerPort', this.$electron.remote.getGlobal('settings').server.port)
    } catch (e) {
      console.error(e)
    }
  },
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
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  h1, h2 {
    font-weight: normal;
  }

  ul {
    list-style-type: none;
    padding: 0;
  }

  li {
    display: inline-block;
    margin: 0 10px;
  }

  a {
    color: rgb(50, 174, 110);
    text-decoration: none;
  }

  a:hover {
    color: rgb(40, 56, 76);
  }

  .server{
    display:flex;
    flex-direction: column;
    align-items: center;
  }
</style>
