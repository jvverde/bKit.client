<template>
    <ul class="directories" v-if="folders.length > 0">
      <li v-for="folder in folders" @click.stop="toggle($index)">
        <div>
	        <div>
		        <icon name="refresh" :spin="true" scale=".9" v-if="isWaiting($index)"></icon>
		        <icon name="folder-open" scale=".9" v-if="folder.open"></icon>
		        <icon name="folder" scale=".9" v-else></icon>
		        <span v-if="hasChildren($index)">
		          <icon name="folder-open-o" scale=".9" v-if="folder.open"></icon>
		          <icon name="folder-o" scale=".9" v-else></icon>
		        </span>
		        <span class="text">{{folder.name}}</span>
	        </div>
	        <a @click.stop=""
	          :href="getUrl('bkit',location,path,folder.name)" title="Recuperar">
	          <icon name="undo" scale=".9"  ></icon>
	        </a>
        </div>
        <directory v-if="folder.open"
          :entries="folder.entries"
          :path="path + encodeURIComponent(folder.name)"
          :location="location">
        </directory>
      </li>
    </ul>
    <ul class="files">
      <li v-for="file in files">
        <div>
	        <div>
		        <icon name="file-o" scale=".9" ></icon>
		        <a :download="file" class="file" @click.stop=""
		          :href="getUrl('download',location,path,file)">
		          <span class="text">{{file}}</span>
		        </a>
	        </div>
	        <div>
		        <a :download="file" @click.stop=""
		          :href="getUrl('download',location,path,file)" title="Download">
		          <icon name="download" scale=".9" ></icon>
		        </a>        
		        <a target="_blank" @click.stop=""
		          :href="getUrl('view',location,path,file)" title="Ver">
		          <icon name="eye" scale=".9" ></icon>
		        </a>
		        <a @click.stop=""
		          :href="getUrl('bkit',location,path,file)" title="Recuperar">
		          <icon name="undo" scale=".9" ></icon>
		        </a>
	        </div>
        </div>
      </li>      
    </ul>  
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
  function getUrl (base, location, path, entry) {
    return server.url + base +
      '/' + location.computer +
      '/' + location.root +
      '/' + location.backup +
      path + encodeURIComponent(entry || '')
  }
  import Icon from 'vue-awesome/src/components/Icon'
  import server from '../config.js'
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

      this.folders = this.entries.folders.map(function (folder) {
        return {name: folder, open: false, entries: {}}
      })
      var self = this
      this.folders.forEach(function (folder) {
        var url = getUrl('folder', self.location, self.path, folder.name)
        self.$http.jsonp(url).then(
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
      getUrl: getUrl,
      toggle (index) {
        this.folders[index].open = !this.folders[index].open
      },
      hasChildren (index) {
        return this.folders[index].entries.folders &&
          this.folders[index].entries.folders.length > 0 ||
          this.folders[index].entries.files &&
          this.folders[index].entries.files.length > 0
      },
      isWaiting (index) {
        return !('folders' in this.folders[index].entries ||
          'files' in this.folders[index].entries)
      }
    }
  }
</script>

<style scoped>
  a.file{
    color: inherit;
  }
</style>
