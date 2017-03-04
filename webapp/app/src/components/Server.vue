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
      <el-button type="primary">Go</el-button>
    </router-link>
    <el-button disabled v-else>Go</el-button>
    <router-link :to="{name: 'Init-page'}" v-if="isValid" class="set">
      Set {{address}} as the Backup Server
    </router-link>
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
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .server{
    display:flex;
    flex-direction: column;
    align-items: center;
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
  }
</style>
