<template>
  <q-page class="flex column remote">
    <section class="flex main">
      <router-view/>
    </section>
    <footer class="flex console" v-if="isElectron">
      <downloads></downloads>
    </footer>
  </q-page>
</template>

<script>
import isElectron from 'is-electron'
const Downloads = () => import('./Console/Downloads')
export default {
  name: 'Remote',
  data () {
    return {
      isElectron: isElectron()
    }
  },
  components: {
    Downloads
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/config.scss";
  .remote{
    width:100%;
    height: 100%;
    overflow: hidden;
    >*{
      width: 100%;
    }
    .main {
      flex-grow:5;
    }
    .console{
      text-align: left;
      margin: 2px;
      padding: 2px;
      background-color: gainsboro;
      border-top: 1px solid $bkit-color;
      flex-grow:0;
    }
  }
</style>
