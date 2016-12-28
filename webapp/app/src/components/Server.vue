<template>
  <div class="server">
    <h1>Server Identification</h1>
    <table>
      <tr>
        <td>Address:</td>
        <td><input v-model="address"></td>
        <td rowspan="2" class="go">
          <a :href="url">Go</a>
        </td>
      </tr>
      <tr>
        <td>Port:</td>
        <td><input v-model="port"></td>
      </tr>
    </table>
    logs:{{log}}
  </div>
</template>

<script>
export default {
  name: 'server',
  created () {
    const spawn = require('child_process').spawn
    const ls = spawn('ls', ['-lh', '.'])

    ls.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`)
      this.log = `${data}`
    })

    ls.stderr.on('data', (data) => {
      console.log(`stderr: ${data}`)
    })

    ls.on('close', (code) => {
      console.log(`child process exited with code ${code}`)
    })
  },
  data () {
    return {
      address: this.$electron.remote.getGlobal('server').address,
      port: this.$electron.remote.getGlobal('server').port,
      log: ''
    }
  },
  computed: {
    url: function () {
      return 'http://' + this.address + ':' + this.port
    }
  },
  methods: {
    go (event) {
      console.log(event.target.tagName)
      console.log('Hello ' + this.address)
    }
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
  .go{
    padding-left:.5em;
    font-size:150%;
  }
</style>
