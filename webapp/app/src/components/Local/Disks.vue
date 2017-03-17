<template>
  <div class="main local">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <breadcrumb></breadcrumb>
    </header>
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
        <subtree :path="d.name" :open="d.open" :parentSelected="false"></subtree>
      </li>
    </ul>
  </div>
</template>

<style scoped lang="scss">
  .main.local{
    display: flex;
    flex-direction: column;
    text-align:left;
    header.top{
      flex-shrink: 0;
      .logo{
        float:left;
      }
    }
    ul.disks{
      overflow: auto;
      list-style: none;
      position:relative;
      margin-left: 1em;
      li.disk{
        display: flex;
        flex-direction: column;
      }

    }
  }
</style>

<script>
  import Breadcrumb from './Breadcrumb'
  import Subtree from './Subtree'
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
      Subtree,
      Breadcrumb
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

