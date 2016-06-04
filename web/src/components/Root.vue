<template>
  <div class="root">
    <div v-for="root in roots">
      <span @click="toggle_root($index)" class="dir">
        {{root.name}}
      </span>
      <backup v-if="root.open" v-for="backup in root.backups"
        :location="{computer:this.computer, root:root.name, backup:backup}">
      </backup>
    </div>
  </div>
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

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .dir{
    cursor: pointer;
  }
</style>
