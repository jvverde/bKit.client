<template>
  <div class="directory">
    <ul class="directories">
      <li v-for="folder in folders" @click.stop="toggle($index)">
        <icon name="folder-o" scale=".8" v-if="folder.open === false"></icon>
        <icon name="folder-open-o" scale=".8" v-else></icon>
        {{folder.name}}
        <directory v-if="folder.open" keep-alive
          :entries="folder.entries"
          :path="path + encodeURIComponent(folder.name)"
          :location="location">
        </directory>
      </li>
    </ul>
    <ul class="files">
      <li v-for="file in files">
        <icon name="file-o" scale=".8"></icon>
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
  import Icon from 'vue-awesome/src/components/Icon'
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
    components: {
      Icon
    },
    created () {
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
        var u = url + encodeURIComponent(folder.name) + '/'
        console.log(u)
        self.$http.jsonp(u).then(
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
      },
      hasChildren (index) {
        return this.folders[index].entries.folders &&
          this.folders[index].entries.folders.length > 0
      }
    }
  }
</script>

<style scoped>

</style>
