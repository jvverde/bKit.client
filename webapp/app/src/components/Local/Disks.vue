<template>
  <ul class="disks">
    <li v-if="loading">
        <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
    </li>
    <li v-for="d in drives">
      <span class="icon is-small">
        <i class="fa"
          :class="{'fa-plus-square-o':!d.open,'fa-minus-square-o':d.open}"
          @click.stop="d.open = !d.open"> </i>
        <i class="fa fa-folder"> </i>
      <span class="icon is-small">
      <span>
        {{d.name}}
      </span>
    </li>
    </li>
  </ul>
</template>

<style scoped lang="scss">

</style>

<script>
  const {spawn} = require('child_process')
  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
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
                return {name: e, open: (this.drives[i] || {}).open}
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

