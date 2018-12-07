<template>
  <span class="datetime">{{datetime}}</span>
</template>

<script>
  var moment = require('moment')
  moment.locale('pt')

  export default {
    name: 'formateddate',
    computed: {
      datetime () {
        return moment.utc(1000 * this.value).local()
          .format('DD-MM-YYYY HH:mm:ss')
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
</style>
