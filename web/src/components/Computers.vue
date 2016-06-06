<template>
  <div class="computers">
    <header>
      <img class="logo" src="../assets/00-Logotipo/256x256.png">
      <h1>{{ msg }} {{name}}</h1>
    </header>
    <ul class="tree">
      <li v-for="computer in computers" class="computer" 
        @click.stop="toggle_roots($index)" >
        <icon name="minus-square-o" scale=".8" v-if="computer.open"></icon>
        <icon name="plus-square-o" scale=".8" v-else></icon>
        <icon name="tv" scale=".8" label="Backup computer"></icon>
        {{computer.name}}
        <root v-if="computer.open"
          :path="{name:computer.name,fullname:computer.id}">
        </root>
      </li>
    </ul>
  </div>
</template>

<script>
  import Root from './Root'
  import Icon from 'vue-awesome/src/components/Icon'
  import server from '../config.js'

  export default {
    data () {
      return {
        msg: 'Bkit!',
        computers: []
      }
    },
    components: {
      Root,
      Icon
    },
    props: ['name'],
    ready () {
      this.$http.jsonp(server.url + 'computers/').then(
        function (response) {
          this.computers = Object.keys(response.data).map(function (key) {
            return {name: key, id: response.data[key], open: false}
          }).sort(function (a, b) {
            return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
          })
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      toggle_roots (index) {
        this.computers[index].open = !this.computers[index].open
      }
    }
  }
</script>

<style>
  li.computer::before{
    display: none;
  }  
</style>
<style scoped>
  .logo {
    width: 5em;
    height: 5em;
  }
  h1 {
    color: #42b983;
    margin-left: 1em;
  }
  header {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: flex-start;
    align-items: center;
    align-content: center;
  }
  ul.tree{
    margin: 0em;
    margin-top: 2em;
    padding-left: 1em;
  }
  ul.tree>li{
    padding-left: 0em;
  }

</style>
