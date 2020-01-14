<template>
  <section class="snapshot">
    <aside class="tree" v-if="rootLocation.disk">
      <div @click.stop="select(rootLocation)"
        :class="{selected: currentLocation.path === rootLocation.path}" 
        class="root">
        <i class="fa fa-hdd-o"></i>
        {{diskName}}
      </div>
      <directory :location="rootLocation"/>
    </aside>
    <files class="content" :location="currentLocation" 
      v-if="currentLocation.path"/>
  </section>
</template>

<script>
  import Directory from './Directory'
  import Files from './Files'
  import { mapGetters, mapMutations } from 'vuex'

  export default {
    name: 'snapshot',
    data () {
      return {
        currentFiles: []
      }
    },
    props: ['rootLocation'],
    computed: {
      ...mapGetters('location', ['getLocation']),
      diskName () {
        const comps = (this.rootLocation.disk || '').split('.')
        return comps[2] === '_' ? comps[0] : comps[2] + (
          comps[0] === '_' ? '' : ` (${comps[0]}:)`
        )
      },
      currentLocation () {
        return this.getLocation
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
      ...mapMutations('location', ['setLocation']),
      select (location) {
        this.setLocation(location)
      }
    }
  }
</script>

<style lang="scss">
  @import "~scss/config.scss";
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
      border-right:1px solid $bkit-color;
      .root.selected {
        background-color: $li-selected;
      }
      .root:hover{
        background-color: $li-hover;
        cursor: pointer;
      }
      &>*{
        margin: 0;
        margin-left: .3em;
      }
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
