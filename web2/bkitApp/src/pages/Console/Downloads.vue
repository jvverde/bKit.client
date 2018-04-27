<template>
  <section class="downloads">
    <resource v-for="(f, i) in downloads" :key="i" :entry="f"></resource>
  </section>
</template>

<script>
import isElectron from 'is-electron'
import Resource from './Resource'
export default isElectron() ? {
  name: 'downloads',
  data () {
    return {
      downloads: []
    }
  },
  components: {
    Resource
  },
  created () {
    console.log('Create download')
    const {ipcRenderer} = require('electron')
    const fs = require('fs')
    ipcRenderer.on('download', (event, arg) => {
      if (arg instanceof Object && arg.type === 'download') {
        if (arg.mimetype === 'application/bkit') {
          const download = arg
          this.downloads.push(download)
          try {
            const file = fs.readFileSync(arg.fullpath)
            download.resource = JSON.parse(file)
            const {computer, backup, entry, path, drive} = download.resource
            download.resource.downloadLocation = arg.fullpath
            const server = this.$store.getters.address
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
            console.log(download.resource.url)

            download.open = true
          } catch (err) {
            this.$notify.error({
              title: `File:${arg.filename}`,
              message: `Error: ${err}`
            })
          }
        } else {
          this.downloads.find(x => x.fullpath === arg.fullpath) ||
            this.downloads.push(arg)
          this.$notify.info({
            title: arg.filename,
            message: 'Download completed'
          })
        }
      }
    })
  },
  mounted () {
    const {ipcRenderer} = require('electron')
    ipcRenderer.send('register', 'download')
  },
  destroy () {
    const {ipcRenderer} = require('electron')
    ipcRenderer.removeAllListeners('download')
  }
} : {
  data () {
    return {
      downloads: []
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
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
