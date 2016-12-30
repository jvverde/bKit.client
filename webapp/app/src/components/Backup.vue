<template>
  <div class="backup">
    <!--<icon name="clone" scale=".9"></icon>-->
    {{location.backup}}
    {{location.computer}}
    {{location.disk}}
<!--     <directory v-if="open"
      :entries="entries"
      path="/"
      :location="location">
    </directory> -->
  </div>
</template>

<script>
  // import Directory from './Directory'
  export default {
    data () {
      return {
        open: false,
        snaps: [],
        location: {}
      }
    },
    components: {
      // Directory
    },
    props: [],
    mounted () {
      this.location = {
        computer: this.$route.params.computer,
        disk: this.$route.params.disk
      }
      let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/' +
        'backup' +
        '/' + this.location.computer +
        '/' + this.location.disk
      this.$http.jsonp(url).then(
        function (response) {
          console.log(response.data)
          // this.$set('snaps', response.data)
          this.snaps = response.data
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

<style scoped>
  .directory{
  }
</style>
