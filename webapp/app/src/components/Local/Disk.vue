<template>
  <li class="disk">
    <div class="header">
      <span class="icon is-small">
        <i class="fa"
          :class="{'fa-plus-square-o':!open,'fa-minus-square-o':open}"
          @click.stop="open = !open"> </i>
        <i @click.stop="toggle" class="fa"
          :class="{
            'fa-square-o': triState === false,
            'fa-check-square-o': triState === true,
            'fa-square': triState === null
          }"> </i>
        <i class="fa fa-folder-o"> </i>
      </span>
      <span>
        {{name}}
      </span>
    </div>
    <subtree v-on:subTreeSelect="subTreeSelect"
      :path="name" 
      :open="open" 
      :parentSelected="selected"
      :class="{closed:!open}" class="subtree">
    </subtree>
  </li>
</template>

<script>
  import Breadcrumb from './Breadcrumb'
  import Subtree from './Subtree'

  export default {
    name: 'disks',
    data () {
      return {
        open: false,
        selected: false,
        descendantTreeStatus: false
      }
    },
    props: ['name'],
    computed: {
      triState () {
        if (this.descendantTreeStatus === null) return null
        else return this.selected
      }
    },
    components: {
      Subtree,
      Breadcrumb
    },
    created () {
    },
    methods: {
      subTreeSelect (status) {
        this.descendantTreeStatus = status
        if (status !== null) {
          this.selected = status
        }
      },
      toggle () {
        this.selected = !this.selected
        this.descendantTreeStatus = false // when a parent is (un)selected the descendant tree is reset
      }
    }
  }
</script>

<style scoped lang="scss">
  li.disk{
    display: flex;
    flex-direction: column;
    .closed{
      display: none;
    }
  }
</style>

