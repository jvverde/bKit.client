<template>
  <span class="datetime" :class="{changed: changed}">{{datetime}}</span>
</template>

<script>
  var moment = require('moment')
  moment.locale('pt')

  export default {
    name: 'formateddate',
    data () {
      return {
        oldvalue: this.value,
        oldpath: this.currentPath
      }
    },
    computed: {
      datetime () {
        return moment.utc(1000 * this.value).local()
          .format('DD-MM-YYYY HH:mm:ss')
      },
      currentSnap () {
        return this.$store.getters.location.snapshot
      },
      currentPath () {
        return this.$store.getters.location.path
      },
      changed () {
        console.log(this.value)
        console.log(this.oldvalue)
        console.log(this.currentPath)
        console.log(this.oldpath)
        return this.value !== this.oldvalue && this.oldpath === this.currentPath
      }
    },
    watch: {
      currentPath (newp, old) {
        console.log('set a new path', newp)
        this.oldpath = old
      },
      currentSnap () {
        this.oldpath = this.currentPath
      },
      value (n, old) {
        this.oldvalue = old
      }
    },
    props: ['value']
  }

</script>

<style scoped>
  span.datetime{
    display: inline-block;
    text-overflow: ellipsis;
    white-space: nowrap;
    padding-left: .2em;
    padding-right: .2em;
  }
  .changed {
    color:red;
  }
</style>
