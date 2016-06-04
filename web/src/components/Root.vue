<template>
  <ul class="root">
    <li v-for="root in roots">
      <span @click="toggle_root($index)" class="dir">
        {{root.name}}
      </span>
      <ul v-if="root.open">
        <backup v-for="backup in root.backups"
          :location="{computer:this.computer, root:root.name, backup:backup}">
        </backup>
      </ul>
    </li>
  </ul>
</template>

<script>
  import Backup from './Backup'
  export default {
    data () {
      return {
        computer: undefined,
        roots: []
      }
    },
    components: {
      Backup
    },
    props: ['path'],
    ready () {
      this.computer = this.path.fullname
      this.$http.jsonp('http://10.1.2.219:8082/backups/' + this.computer).then(
        function (response) {
          this.roots = Object.keys(response.data).map(function (key) {
            return {name: key, backups: response.data[key], open: false}
          })
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      toggle_root (index) {
        this.roots[index].open = !this.roots[index].open
      }
    }
  }
</script>

<style scoped>
  .dir{
    cursor: pointer;
  }
</style>
