<template>
  <section class="downloads">
    <resource v-for="entry in downloads" :entry="entry"></resource>
  </section>
</template>

<script>
import Resource from './Resource'
const {ipcRenderer} = require('electron')
const fs = require('fs')
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
    ipcRenderer.on('download', (event, arg) => {
      if (arg instanceof Object && arg.type === 'download') {
        this.downloads.find(x => x.fullpath === arg.fullpath) || this.downloads.push(arg)
        this.$notify.info({
          title: arg.filename,
          message: 'Download completed'
        })
        if (arg.mimetype === 'application/bkit') {
          let download = this.downloads.find(x => x.fullpath === arg.fullpath)
          try {
            let file = fs.readFileSync(arg.fullpath)
            download.resource = JSON.parse(file)
            download.resource.downloadLocation = arg.fullpath
            download.open = true
          } catch (err) {
            this.$notify.error({
              title: `File:${arg.filename}`,
              message: `Error: ${err}`
            })
          }
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
    max-height: 25%;
    overflow-y:auto;
    overflow-x:hidden;
    width: 100%;
  }
</style>
