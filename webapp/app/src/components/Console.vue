<template>
  <el-tabs type="card" class="console">
    <el-tab-pane label="Downloads" v-if="downloads[0]" class="panel">
      <downloads></downloads>
    </el-tab-pane>
    <el-tab-pane label="Recovery" v-if="resource.downloadLocation" class="panel">
      <recovery :resource="resource"></recovery>
    </el-tab-pane>
  </el-tabs>
</template>

<script>
import Recovery from './Console/Recovery'
import Downloads from './Console/Downloads'

export default {
  name: 'console',
  data () {
    return {
      resource: {}
    }
  },
  components: {
    Recovery,
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
  .console{
    max-height: 50%;
    overflow: hidden;
    width: 100%;
    text-align: left;
    margin: 2px;
    padding: 2px;
    background-color: #EEE;
    .panel{
      overflow: auto;
      height: 10em;
    }
    li{
      display:flex;
      flex-wrap:nowrap;
      justify-content:space-between;
    }
  }
</style>
