<template>
    <li class="dir">
      <div class="header">
        <span class="icon is-small">
          <i class="fa"
            :class="{'fa-plus-square-o':!open,'fa-minus-square-o':open}"
            @click.stop="open = !open"> </i>
          <i class="fa"
            :class="{
              'fa-square-o': triState === false,
              'fa-check-square-o': triState === true,
              'fa-square': triState === null
            }"
            @click.stop="toggle"> </i>
          <i class="fa fa-folder-o"> </i>
        </span>
        <span>
          {{entry.name}}
        </span>
      </div>
      <subtree :path="entry.path" :open="open"
        :parentSelected="isSelected"
        v-on:subTreeSelect="subTreeSelect"
        :class="{closed:!open}" class="subtree">
      </subtree>
    </li>
</template>

<script>
  import Subtree from './Subtree'

  export default {
    name: 'directory',
    data () {
      return {
        open: false,
        selected: null,           // tri-state
        descendantSelected: false
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
      },
      triState () {
        if (this.descendantSelected === false) return this.isSelected
        else return this.descendantSelected
      }
    },
    watch: {
      parentSelected () {
        this.descendantSelected = false
        this.selected = false
        this.$nextTick(() => { // this is a trick to force a parentSelected change and propagates down to childrens
          this.selected = null // this is what it should be at the end
        })
      },
      selected () {
        const entry = {
          path: this.entry.path,
          dir: true
        }
        if (this.selected === true) {
          this.$store.dispatch('incBackupDir', entry)
        } else if (this.selected === false) {
          this.$store.dispatch('excBackupDir', entry)
        } else if (this.selected === null) {
          this.$store.dispatch('rmBackupDir', entry)
        }
      }
    },
    created () {
    },
    methods: {
      toggle () {
        if (this.selected === null) this.selected = !this.parentSelected
        else this.selected = !this.selected
        this.descendantSelected = false
        this.$emit('subDirSelect')
      },
      subTreeSelect (status) {
        console.log(this.entry.path, 'received a status', status)
        this.descendantSelected = status
        if (status !== null) {
          // if subtree is all (un)selected then set (un)select flag
          if (this.parentSelected === status) this.selected = null
          // if current status equal to parent don't flag it. Use parent selection.
          else this.selected = status
        }
        console.log(this.entry.path, '=>', this.selected)
        this.$emit('subDirSelect')
      }
    }
  }
</script>

<style scoped lang="scss">
  .subtree.closed{
    display: none;
  }
</style>
