<template>
  <section class="downloads">
    <!--resource v-for="(f, i) in downloads" :key="i" :entry="f"></resource-->
  </section>
</template>

<script>
import Resource from './Resource'
const {ipcRenderer, remote} = require('electron')
const fs = remote.require('fs')
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
  created () {
    console.log('Create download')
    ipcRenderer.on('download', (event, arg) => {
      if (arg instanceof Object && arg.type === 'download') {
        // this.downloads.find(x => x.fullpath === arg.fullpath) || this.downloads.push(arg)
        if (arg.mimetype === 'application/bkit') {
          // const oldIndex = this.downloads.findIndex(
          //   x => x.fullpath === arg.fullpath
          // )
          const download = arg
          this.downloads.push(download)
          // if (oldIndex !== -1) {
          //   this.$nextTick(() => {
          //     this.downloads.splice(oldIndex, 1)
          //   })
          // }
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
    ipcRenderer.send('register', 'download')
  },
  destroy () {
    ipcRenderer.removeAllListeners('download')
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
