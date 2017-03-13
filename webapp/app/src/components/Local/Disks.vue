<template>
  <ul class="disks">
    <li v-if="loading">
        <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
    </li>

    </li>
  </ul>
</template>

<style scoped lang="scss">

</style>

<script>

  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'

  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }

  export default {
    name: 'disks',
    data () {
      return {

      }
    },
    props: {
    },
    computed: {
    },
    watch: {
    },
    components: {e
    },
    created () {
      this.refresh()
    },
    methods: {
      refresh () {
        try {
          
        } catch (e) {
          this.loading = false
          console.error(e)
        }
      }
    }
  }
</script>

