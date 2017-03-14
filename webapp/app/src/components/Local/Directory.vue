<template>
  <ul class="directory" :class="{closed:!open}">
    <li v-for="d in directories" class="dir">
      <div class="header">
        <span class="icon is-small">
          <i class="fa"
            :class="{'fa-plus-square-o':!d.open,'fa-minus-square-o':d.open}"
            @click.stop="d.open = !d.open"> </i>
          <i class="fa fa-folder-o"> </i>
        </span>
        <span>
          {{d.name}}
        </span>
      </div>
      <directory :path="d.path" :open="d.open"></directory>
    </li>
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
    name: 'directory',
    data () {
      return {
        directories: [],
        files: []
      }
    },
    props: ['path', 'open'],
    computed: {
    },
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
            const older = this.directories.find(e => e.path === fullpath) || {open: false}
            return {name: e, path: fullpath, directory: isDirectory(fullpath), open: older.open}
          })
          this.directories = entries.filter(e => e.directory).sort(order)
          this.files = entries.filter(e => !e.directory).sort(order)
        }
      }
    }
  }
</script>

<style scoped lang="scss">
  ul.directory{
    padding-left: 1em;
    list-style: none;
  }
  ul.directory.closed{
    display: none;
  }
</style>
