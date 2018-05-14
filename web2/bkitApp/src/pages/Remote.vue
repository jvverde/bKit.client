<template>
  <q-page class="flex column no-wrap remote">
<!--     <section class="flex main">
      <router-view/>
    </section>
    <footer class="flex console" v-if="isElectron">
      <downloads></downloads>
    </footer> -->
    <q-tabs v-if="isElectron" no-pane-border>
      <q-tab default name="files" slot="title" icon="mail" label="files" />
      <q-tab name="logs" slot="title" icon="alarm" label="Console"/>
      <q-tab-pane name="files" keep-alive>
        <router-view/>
      </q-tab-pane>
      <q-tab-pane name="logs" keep-alive>
        <downloads></downloads>
      </q-tab-pane>
    </q-tabs>
    <section class="flex main" v-else>
      <router-view/>
    </section>
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
      flex-shrink:1;
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
