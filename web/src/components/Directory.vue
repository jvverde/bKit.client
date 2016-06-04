<template>
  <div class="directory">
    subdirs
    <div class="directories">
      <div v-for="children in childrens" @click.stop="toggle($index)">
        {{children.name}}
        <b v-if="children.folders.length > 0">
          {{children.folders.length}}
        </b>
        <directory v-if="children.open" 
          :entries="children.entries"
          :path="'/' + children.name + '/'"
          :location="location">
        </directory>
      </div>
    </div>
    Files
    <div class="files">
      <div v-for="file in files">
        {{file}}
      </div>      
    </div>
  </div>
</template>

<script>
const requiredString = {
  type: String,
  required: true
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
      childrens: {},
      files: []
    }
  },
  props: {
    location: requiredLocation,
    path: requiredString,
    entries: requiredEntries
  },
  ready () {
    console.log('Computer:', this.location.computer)
    console.log('Root:', this.location.root)
    console.log('Backup:', this.location.backup)
    console.log('Path:', this.path)
    this.files = this.entries.files
    var url = 'http://10.1.2.219:8082/folder' +
      '/' + this.location.computer +
      '/' + this.location.root +
      '/' + this.location.backup +
      this.path
    this.childrens = this.entries.folders.map(function (folder) {
      return {name: folder, folders: [], files: [], open: false, entries: {}}
    })
    var self = this
    this.childrens.forEach(function (children) {
      console.log(url + children.name + '/')
      self.$http.jsonp(url + children.name + '/').then(
        function (response) {
          children.entries = response.data
          children.folders = response.data.folders
          children.files = response.data.files
        },
        function (response) {
          console.error(response)
        }
      )
    })
  },
  methods: {
    toggle (index) {
      this.childrens[index].open = !this.childrens[index].open
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
