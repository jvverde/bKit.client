<template>
  <div class="main local">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <breadcrumb></breadcrumb>
    </header>
    <section>
      <span>Backup Now</span>
      <router-link to="/job">Create a backup Job</router-link>
    </section>
    <ul class="disks">
      <li v-if="loading">
          <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
      </li>
      <disk v-for="d in drives" :name="d"></disk>
    </ul>
  </div>
</template>

<script>
  import Breadcrumb from './Breadcrumb'
  import Disk from './Disk'
  const {spawn} = require('child_process')
  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
  const path = require('path')

  function order (a, b) {
    return (a > b) ? 1 : ((b > a) ? -1 : 0)
  }
  export default {
    name: 'disks',
    data () {
      return {
        drives: []
      }
    },
    components: {
      Disk,
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
              this.drives = drives.sort(order).map(e => path.join(e, '/'))
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
    }
  }
</style>