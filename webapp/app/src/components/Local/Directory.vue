<template>
    <li class="dir" :class="{closed:!open}">
      <div class="header">
        <span class="icon is-small">
          <i class="fa"
            :class="{'fa-plus-square-o':!open,'fa-minus-square-o':open}"
            @click.stop="open = !open"> </i>
          <i class="fa"
            :class="{'fa-square-o': !isSelected, 'fa-check-square-o': isSelected}"
            @click.stop="select"> </i>
          <i class="fa fa-folder-o"> </i>
        </span>
        <span>
          {{entry.name}}
        </span>
      </div>
      <subtree :path="entry.path" :open="open" :parentSelected="isSelected"></subtree>
    </li>
</template>

<script>
  import Subtree from './Subtree'

  export default {
    name: 'directory',
    data () {
      return {
        open: false,
        selected: null // tri-state
      }
    },
    components: {
      Subtree
    },
    props: ['entry', 'parentSelected'],
    computed: {
      isSelected () {
        if (this.selected === null) return this.parentSelected
        else return this.selected
      }
    },
    watch: {
      parentSelected () {
        this.selected = null
      }
    },
    created () {
    },
    methods: {
      select () {
        this.selected = !this.selected
      }
    }
  }
</script>

<style scoped lang="scss">
  ul.dir.closed{
    display: none;
  }
</style>
