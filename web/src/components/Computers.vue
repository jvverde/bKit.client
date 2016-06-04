<template>
  <div class="computers">
    <h1>{{ msg }} {{name}}</h1>
    <div v-for="computer in computers">
      <span @click="toggle_roots($index)" class="computer">
        {{computer.name}}
      </span>
      <root v-if="computer.open"
        :path="{name:computer.name,fullname:computer.id}">
      </root>
    </div>
  </div>
</template>

<script>
  import Root from './Root'
  export default {
    data () {
      return {
        msg: 'Bkit!',
        computers: []
      }
    },
    components: {
      Root
    },
    props: ['name'],
    ready () {
      this.$http.jsonp('http://10.1.2.219:8082/computers').then(
        function (response) {
          this.computers = Object.keys(response.data).map(function (key) {
            return {name: key, id: response.data[key], open: false}
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

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1 {
    color: #42b983;
  }
  .computer{
    cursor: pointer;
  }
</style>
