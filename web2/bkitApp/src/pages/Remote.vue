<template>
  <q-page class="flex flex-center">
    <router-view/>
    <footer class="bottom console">
      <downloads></downloads>
    </footer>
  </q-page>
</template>

<script>
import Downloads from './Console/Downloads'
export default {
  name: 'PageRemote',
  components: {
    Downloads
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/config.scss";
  .console{
    text-align: left;
    margin: 2px;
    padding: 2px;
    background-color: gainsboro;
    border-top: 1px solid $bkit-color;
    display:flex;
    width: 100%;
  }
</style>
