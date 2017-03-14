<template>
  <div class="main local">
    <bkitlogo class="logo"></bkitlogo>
    <ul class="disks">
      <li v-if="loading">
          <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
      </li>
      <li v-for="d in drives" class="disk">
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
        <directory :path="d.name" :open="d.open"></directory>
      </li>
    </ul>
  </div>
</template>

<style scoped lang="scss">
  .main.local{
    display: flex;
    flex-direction: column;
    text-align:left;
    .logo {
      flex-shrink: 0;
    }
    ul.disks{
      overflow: auto;
      list-style: none;
      position:relative;
      li.disk{
        display: flex;
        flex-direction: column;
      }

    }
  }
</style>

<script>
  import Directory from './Directory'
  const {spawn} = require('child_process')
  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
  const path = require('path')

/*
  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }
*/
  export default {
    name: 'disks',
    data () {
      return {
        drives: []
      }
    },
    props: {
    },
    computed: {
    },
    watch: {
    },
    components: {
      Directory
    },
    created () {
      this.refresh()
    },
    methods: {
      refresh () {
        try {
          const fd = spawn(BASH, ['./listDisks.sh'], {cwd: '..'})
          let output = ''
          fd.stdout.on('data', (data) => {
            output += `${data}`
          })
          fd.stderr.on('data', (msg) => {
            this.$notify.error({
              title: 'Error',
              message: `${msg}`,
              customClass: 'message error'
            })
          })
          fd.on('close', () => {
            const drives = output.replace(/\n$/, '').split(/\n/)
            console.log('drives:', drives)
            this.$nextTick(() => {
              this.drives = drives.map((e, i) => {
                return {name: path.join(e, '/'), open: (this.drives[i] || {}).open}
              })
              this.loading = false
            })
          })
        } catch (e) {
          this.loading = false
          console.error(e)
        }
      }
    }
  }
</script>

