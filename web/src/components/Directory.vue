<template>
  <div class="directory">
    <ul class="directories">
      <li v-for="folder in folders" @click.stop="toggle($index)">
        {{folder.name}}
        <b v-if="folder.entries.folders && folder.entries.folders.length > 0">
          ({{folder.entries.folders.length}})
        </b>
        <directory v-if="folder.open" 
          :entries="folder.entries"
          :path="path + folder.name"
          :location="location">
        </directory>
      </li>
    </ul>
    <ul class="files tree">
      <li v-for="file in files">
        {{file}}
      </li>      
    </ul>
  </div>
</template>

<script>
  const requiredString = {
    type: String,
    required: true,
    coerce (val) {
      return val.replace(/\/?$/, '/')
    }
  }
  const requiredLocation = {
    type: Object,
    required: true,
    validator: function (obj) {
      return obj.computer && obj.root && obj.backup
    }
  }
  const requiredEntries = {
    type: Object,
    required: true,
    validator: function (obj) {
      return obj.folders instanceof Array
    }
  }
  export default {
    name: 'directory',
    data () {
      return {
        folders: [],
        files: []
      }
    },
    props: {
      location: requiredLocation,
      path: requiredString,
      entries: requiredEntries
    },
    ready () {
      this.files = this.entries.files
      var url = 'http://10.1.2.219:8082/folder' +
        '/' + this.location.computer +
        '/' + this.location.root +
        '/' + this.location.backup +
        this.path
      this.folders = this.entries.folders.map(function (folder) {
        return {name: folder, open: false, entries: {}}
      })
      var self = this
      this.folders.forEach(function (folder) {
        console.log(url + folder.name + '/')
        self.$http.jsonp(url + folder.name + '/').then(
          function (response) {
            folder.entries = response.data
          },
          function (response) {
            console.error(response)
          }
        )
      })
    },
    methods: {
      toggle (index) {
        this.folders[index].open = !this.folders[index].open
      }
    }
  }
</script>

<style scoped>
  .directory{

  }
</style>
