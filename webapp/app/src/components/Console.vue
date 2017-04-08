<template>
  <div class="console">
      <downloads></downloads>
  </div>
</template>

<script>
import Downloads from './Console/Downloads'

export default {
  name: 'console',
  data () {
    return {
      resource: {}
    }
  },
  components: {
    Downloads
  },
  created () {
  },
  methods: {
  },
  destroyed () {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../config.scss";
  .console{
    text-align: left;
    margin: 2px;
    padding: 2px;
    background-color: gainsboro;
    border-top: 1px solid $bkit-color;
    display:flex;
    width: 100%
  }
</style>
