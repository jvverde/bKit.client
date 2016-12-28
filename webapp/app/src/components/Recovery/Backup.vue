<template>
  <li class="backup" @click.stop="toggle">
    <icon name="clone" scale=".9" v-if="open"></icon>
    <icon name="clone" scale=".9" v-else></icon>
    <!--<icon name="clone" scale=".9"></icon>-->
    {{location.backup}}
    <directory v-if="open"
      :entries="entries"
      path="/"
      :location="location">
    </directory>
  </li>
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
    mounted () {
      let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/' +
        'folder' +
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

<style scoped>
  .directory{
  }
</style>
