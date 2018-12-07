<template>
  <section class="snapshot">
    <aside class="tree" v-if="rootLocation.disk">
      <div @click.stop="select(rootLocation)" class="root">{{diskName}}</div>
      <directory :location="rootLocation">
      </directory>
    </aside>
    <files class="content" :location="currentLocation" 
      v-if="currentLocation.path">
    </files>
  </section>
</template>

<script>
  import Directory from './Directory'
  import Files from './Files'

  export default {
    name: 'snapshot',
    data () {
      return {
        currentFiles: []
      }
    },
    props: ['rootLocation'],
    computed: {
      diskName () {
        const comps = (this.rootLocation.disk || '').split('.')
        return comps[2] === '_' ? comps[0] : comps[2] + (
          comps[0] === '_' ? '' : ` (${comps[0]}:)`
        )
      },
      currentLocation () {
        return this.$store.getters.location
      }
    },
    components: {
      Directory,
      Files
    },
    mounted () {
      this.select(this.rootLocation)
    },
    methods: {
      select (location) {
        this.$store.dispatch('setLocation', location)
      }
    }
  }
</script>

<style lang="scss">
  @import "../../config.scss";
  .snapshot {
    width:100%;
    height: 100%;
    display: flex;
    text-align: left;
    .root:hover{
      background-color: $li-hover;
      cursor: pointer;
    }
    .content {
      flex-grow:1;
      overflow: auto;
      padding-left:5px;
    }
    .tree{
      overflow: auto;
      border-right:1px solid $bkit-color;
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
