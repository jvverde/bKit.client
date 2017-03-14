<template>
    <li class="dir">
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
      <subtree :path="entry.path" :open="open" :parentSelected="isSelected" :class="{closed:!open}" class="subtree"></subtree>
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
        if (this.selected === null) this.selected = !this.parentSelected
        else this.selected = !this.selected
      }
    }
  }
</script>

<style scoped lang="scss">
  .subtree.closed{
    display: none;
  }
</style>
