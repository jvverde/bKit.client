<template>
  <ul class="subtree">
    <directory v-for="(d, index) in directories"
      v-on:subDirSelect="subDirSelect"
      ref="subdirs"
      :entry="{path:d.path, name: d.name, index: index}" :parentSelected="parentSelected">
    </directory>
    <li v-for="file in files" class="file">
      <span class="icon is-small">
        <i class="fa"
          :class="{
            'fa-square-o': !file.selected,
            'fa-check-square-o': file.selected
          }"
          @click.stop="toggle(file)"> </i>
        <i class="fa fa-file-o"> </i>
      </span>
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
      },
      parentSelected () {
        this.files.forEach(e => {
          e.selected = this.parentSelected
        })
      }
    },
    computed: {
      subdirs () {
        return this.$refs.subdirs || []
      },
      isDirsAll () {
        return this.subdirs.every(e => e.triState === true)
      },
      isDirsClear () {
        return this.subdirs.every(e => e.triState === false)
      },
      isFilesAll () {
        return this.files.every(e => e.selected === true)
      },
      isFilesClear () {
        return this.files.every(e => e.selected === false)
      },
      isAllSelected () {
        return this.isFilesAll && this.isDirsAll
      },
      isAllUnselected () {
        return this.isFilesClear && this.isDirsClear
      }
    },
    created () {
      this.refresh()
    },
    methods: {
      refresh () {
        if (this.open) {
          try {
            const entries = fs.readdirSync(this.path).map(e => {
              const fullpath = path.join(this.path, e)
              const older = this.directories.find(e => e.path === fullpath) || {}
              return Object.assign({}, older, {name: e, path: fullpath, directory: isDirectory(fullpath)})
            })
            this.directories = entries.filter(e => e.directory).sort(order)
            this.files = entries.filter(e => !e.directory).sort(order)
              .map(e => Object.assign(e, {selected: this.parentSelected}))
          } catch (e) {
            console.warn(e)
          }
        }
      },
      subDirSelect () { // called every time a sub dir is (un)selected
        if (this.isAllSelected) return this.$emit('subTreeSelect', true)
        if (this.isAllUnselected) return this.$emit('subTreeSelect', false)
        this.$emit('subTreeSelect', null)
      },
      toggle (file) {
        file.selected = !file.selected
        this.subDirSelect()
      }
    }
  }
</script>

<style scoped lang="scss">
  .subtree{
    padding-left: 1em;
    list-style: none;
    .file{
      margin-left: 1em;
    }
  }
</style>
