<template>
  <section class="snapshot">
    <directory class="tree" v-on:select="select"
      :location="rootLocation" v-if="rootLocation.path">
    </directory>
    <files class="content" :location="currentLocation" v-if="currentLocation.path">
    </files>
  </section>
</template>

<script>
  import Directory from './Directory'
  import Files from './Files'

  const requiredString = {
    type: String,
    required: true,
    validator: function (w) {
      return w.length > 0
    }
  }

  export default {
    name: 'snapshot',
    data () {
      return {
        rootLocation: {},
        currentLocation: {},
        currentFiles: []
      }
    },
    props: {
      computer: requiredString,
      disk: requiredString,
      id: requiredString
    },
    components: {
      Directory,
      Files
    },
    mounted () {
      this.rootLocation = this.currentLocation = {
        computer: this.computer,
        disk: this.disk,
        snapshot: this.id,
        path: '/'
      }
    },
    methods: {
      select (location) {
        this.currentLocation = location
        console.log(location.path)
      }
    }
  }
</script>

<style lang="scss">
  .snapshot {
    width:100%;
    height: 100%;
    display: flex;
    text-align: left;
    .content {
      flex-grow:1;
      overflow: auto;
      padding-left:5px;
    }
    .tree{
      overflow: auto;
      border-right:1px solid black;
    }
    a{
      color: inherit;
      .icon:hover{
        color: #090;
      }
    }
    a:active{
      border:1px solid red;
    }
  }
</style>
