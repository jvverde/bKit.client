<template>
  <span>{{datetime}}</span>
</template>

<script>
  var moment = require('moment')
  moment.locale('pt')

  export default {
    name: 'formateddate',
    data () {
      return {
        datetime: moment.utc(1000 * this.value).local()
          .format('DD-MM-YYYY HH:mm:ss')
      }
    },
    props: ['value']
  }

</script>

<style scoped>

</style>
