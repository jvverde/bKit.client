<template>
  <ul class="subtree">
    <directory v-for="d in directories" :entry="{path:d.path, name: d.name, parentSelected: parentSelected}"></directory>
    <li v-for="file in files" class="file">
      <span>{{file.name}}</span>
    </li>
  </ul>
</template>

<script>
  const path = require('path')
  const fs = require('fs')
  function isDirectory (path) {
    let result = false
    try {
      result = fs.statSync(path).isDirectory()
    } catch (e) {
      console.warn(e)
      result = false
    }
    return result
  }
  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }
  export default {
    name: 'subtree',
    beforeCreate: function () {
      this.$options.components.Directory = require('./Directory.vue')
    },
    data () {
      return {
        directories: [],
        files: []
      }
    },
    props: ['path', 'open', 'parentSelected'],
    watch: {
      open () {
        this.refresh()
      }
    },
    created () {
      this.refresh()
    },
    methods: {
      refresh () {
        if (this.open) {
          console.log('refresh', this.path)
          const entries = fs.readdirSync(this.path).map(e => {
            const fullpath = path.join(this.path, e)
            const older = this.directories.find(e => e.path === fullpath) || {}
            return Object.assign({}, older, {name: e, path: fullpath, directory: isDirectory(fullpath)})
          })
          this.directories = entries.filter(e => e.directory).sort(order)
          this.files = entries.filter(e => !e.directory).sort(order)
        }
      }
    }
  }
</script>

<style scoped lang="scss">
  ul.subtree{
    padding-left: 1em;
    list-style: none;
  }
</style>
