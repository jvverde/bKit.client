<template>
  <div>
    <breadcrumb :computer="computer" :disk="disk" :snap="id"></breadcrumb>
    <directory class="root"
      :entries="entries"
      path="/"
      :location="{computer:computer, disk:disk, snapshot:id}">
    </directory> 
  </div>
</template>

<script>
  import Directory from './Directory'
  import Breadcrumb from './Breadcrumb'
  
  function refresh () {
    let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/' +
      'folder' +
      '/' + this.computer +
      '/' + this.disk +
      '/' + this.id + '/'
    let self = this
    this.$http.jsonp(url).then(
      function (response) {
        self.$set(self, 'entries', response.data)
      },
      function (response) {
        console.error(response)
      }
    )
  }

  const requiredString = {
    type: String,
    required: true,
    validator: function (w) {
      return w.length > 0
    }
  }

  export default {
    name: 'snapshot',
    data () {
      return {
        entries: {}
      }
    },
    props: {
      computer: requiredString,
      disk: requiredString,
      id: requiredString
    },
    components: {
      Directory,
      Breadcrumb
    },
    created: refresh,
    watch: {
      id: refresh
    },
    methods: {

    }
  }
</script>

<style scoped>

</style>
