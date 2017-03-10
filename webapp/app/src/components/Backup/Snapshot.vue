<template>
  <section class="snapshot">
    <aside class="tree" >
      <div @click.stop="select(rootLocation)" class="root">{{diskName}}</div>
      <directory :location="rootLocation" v-if="rootLocation.path">
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
        currentFiles: []
      }
    },
    props: {
      computer: requiredString,
      disk: requiredString,
      id: requiredString
    },
    computed: {
      diskName () {
        const comps = this.disk.split('.')
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
      this.rootLocation = {
        computer: this.computer,
        disk: this.disk,
        snapshot: this.id,
        path: '/'
      }
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
