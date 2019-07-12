<template>
  <section class="downloads">
    <resource v-for="(f, i) in downloads" :key="i" :entry="f"></resource>
  </section>
</template>

<script>
import Resource from './Resource'
import {myMixin} from 'src/mixins'
const {ipcRenderer} = require('electron')
const fs = require('fs')
console.log('Downloads....')
const type = 'application/bkit'

export default {
  name: 'downloads',
  data () {
    return {
      downloads: []
    }
  },
  components: {
    Resource
  },
  mixins: [myMixin],
  created () {
    console.log('Create download area')
    ipcRenderer.on(type, (event, download) => {
      const file = fs.readFileSync(download.fullpath)
      download.resource = JSON.parse(file)
      const {computer, backup, entry, path, drive, server} = download.resource
      download.resource.downloadLocation = download.fullpath
      download.resource.url = [
        `rsync://user@${server}:8731`,
        computer,
        drive,
        '.snapshots',
        backup,
        'data',
        path,
        '.',
        entry
      ].join('/')
      console.log('Download from :', download.resource.url)
      download.open = true
      this.downloads.push(download)
    })
    ipcRenderer.send('openResource', type)
  },
  destroy () {
    ipcRenderer.removeAllListeners('openResource')
  }
}
</script>

<style scoped lang="scss">
  .downloads{
    display: flex;
    flex-direction: column;
    overflow-y:auto;
    overflow-x:hidden;
    width: 100%;
    * {
      flex-shrink:0;
    }
  }
</style>
