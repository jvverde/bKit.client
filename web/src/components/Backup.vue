<template>
  <div class="backup" @click="toggle">
    <slot>Backup:{{location.backup}}</slot>
    <directory v-if="open" 
      :entries="entries"
      path="/"
      :location="location">
    </directory>
  </div>
</template>

<script>
  import Directory from './Directory'
  export default {
    data () {
      return {
        open: false,
        entries: []
      }
    },
    components: {
      Directory
    },
    props: ['location'],
    ready () {
      var url = 'http://10.1.2.219:8082/folder' +
        '/' + this.location.computer +
        '/' + this.location.root +
        '/' + this.location.backup
      this.$http.jsonp(url).then(
        function (response) {
          this.$set('entries', response.data)
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      toggle () {
        this.open = !this.open
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .directory{
    border: 1px solid red;
  }
</style>
