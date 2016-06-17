<template>
  <ul class="root">
    <li v-for="root in roots" @click.stop="toggle_root($index)">
      <icon name="database" scale=".9" v-if="root.open"></icon>
      <icon name="database" scale=".9" v-else></icon>
      <!--<icon name="database" scale=".9"></icon>-->
      {{root.name}}
      <ul v-if="root.open">
        <backup v-for="backup in root.backups | orderBy -1"
          :location="{computer:this.computer, root:root.name, backup:backup}">
        </backup>
      </ul>
    </li>
  </ul>
</template>

<script>
  import Backup from './Backup'
  import Icon from 'vue-awesome/src/components/Icon'
  import server from '../config.js'
  export default {
    data () {
      return {
        computer: undefined,
        roots: []
      }
    },
    components: {
      Backup,
      Icon
    },
    props: ['path'],
    ready () {
      this.computer = this.path.fullname
      this.$http.jsonp(server.url + 'backups/' + this.computer).then(
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
