<template>
  <li class="backup" @click.stop="toggle">
    <icon name="minus-square-o" scale=".8" v-if="open"></icon>
    <icon name="plus-square-o" scale=".8" v-else></icon>
    <icon name="clone" scale=".8"></icon>
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
  import Icon from 'vue-awesome/src/components/Icon'

  export default {
    data () {
      return {
        open: false,
        entries: []
      }
    },
    components: {
      Directory,
      Icon
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

<style scoped>
  .directory{
  }
</style>
