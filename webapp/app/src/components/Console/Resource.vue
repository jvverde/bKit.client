<template>
  <div class="resource" :class="{open:open}">
    <section>
      <header>{{entry.filename}}</header>
      <aside v-if="entry.resource">
<!--         <span class="icon is-small" @click.prevent="run">
          <i class="fa fa-cogs"></i>
        </span> -->
        <span class="icon is-small" @click.prevent="open = !open">
          <i class="fa fa-chevron-circle-right" :class="{'fa-rotate-90':open}"></i>
        </span>
      </aside>
      <aside v-else>
        <span class="icon is-small" @click.prevent="openFile">
          <i class="fa fa-eye"></i>
        </span>
         <span class="icon is-small" @click.prevent="showFolder">
          <i class="fa fa-folder-o"></i>
        </span>
      </aside>
    </section>
    <recovery :resource="recovery" :show="open" v-for="recovery in recoveries" v-if="recovery"></recovery>
  </div>
</template>

<script>
import Recovery from './Recovery'
const {shell} = require('electron')
export default {
  name: 'downloads',
  data () {
    return {
      open: this.entry.resource instanceof Object,
      recoveries: [this.entry.fullpath]
    }
  },
  props: ['entry'],
  components: {
    Recovery
  },
  created () {
    console.log(this.entry)
  },
  mounted () {
  },
  methods: {
    openFile () {
      shell.openItem(this.entry.fullpath)
    },
    showFolder () {
      shell.showItemInFolder(this.entry.fullpath)
    },
    run () {
      this.recoveries.push(this.recoveries[0])
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .resource{
    display:flex;
    flex-direction: column;
    width: 100%;
    section{
      width: 100%;
      display:flex;
      flex-wrap:nowrap;
      justify-content:space-between;
      padding:2px;
      i{
        cursor: pointer;
      }
    }
  }
</style>
