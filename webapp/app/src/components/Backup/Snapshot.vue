<template>
  <div>
   id:{{id}}
  </div>  
</template>

<script>
  function refresh () {
    console.log(this.id)
    let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/' +
      'folder' +
      '/' + this.computer +
      '/' + this.disk +
      '/' + this.id +
      '/' + this.path
    this.$http.jsonp(url).then(
      function (response) {
        console.log(response.data)
      },
      function (response) {
        console.error(response)
      }
    )
  }
  export default {
    name: 'directory',
    data () {
      return {
        folders: [],
        files: [],
        path: ''
      }
    },
    props: ['computer', 'disk', 'id'],
    components: {
    },
    created () {
      console.log('created')
    },
    mounted: refresh,
    beforeUpdate: refresh,
    methods: {

    }
  }
</script>

<style scoped>

</style>
