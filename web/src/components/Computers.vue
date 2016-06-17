<template>
  <div class="computers">
    <header>
      <img class="logo" src="../assets/00-Logotipo/128x128.png">
      <h1>bK<span style="color:#67a9fb">i</span><span style="color:#7fff00">t</span></h1><br/>
      
    </header>
    <ul class="tree">
      <li v-for="computer in computers" class="computer" 
        @click.stop="toggle_roots($index)" >
        <icon name="desktop" scale=".9" v-if="computer.open"></icon>
        <icon name="desktop" scale=".9" v-else></icon>
        <!--<icon name="desktop" scale=".9" label="Backup computer"></icon>-->
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
    width: 9em;
    height: 9em;
    padding:25px;
  }
  h1 {
    color: #777777;
    font-size:120px;
    position:relative;
    left:15px;
    top:0px;
    
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
    margin-top: 1em;
    padding-left: 1em;
  }
  ul.tree>li{
    padding-left: 1em;
  }
  
</style>
