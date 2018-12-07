<template>
    <li class="file">
      <span class="icon is-small">
        <i class="fa"
          :class="{
            'fa-square-o': !isSelected,
            'fa-check-square-o': isSelected
          }"
          @click.stop="toggle()"> </i>
        <i class="fa fa-file-o"> </i>
      </span>
      <span>{{name}}</span>
    </li>
</template>

<script>
  export default {
    name: 'file',
    data () {
      return {
        selected: null
      }
    },
    props: ['name', 'path', 'parentSelected'],
    watch: {
      parentSelected () {
        this.selected = null
      },
      selected () {
        const entry = {
          path: this.path,
          file: true
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
    computed: {
      isSelected () {
        if (this.selected === null) return this.parentSelected
        else return this.selected
      }
    },
    created () {
    },
    methods: {
      toggle () {
        if (this.selected === null) this.selected = !this.parentSelected
        else this.selected = !this.selected
        this.$emit('fileSelect', this.selected)
      }
    }
  }
</script>

<style scoped lang="scss">
  .subtree{
    padding-left: 1em;
    list-style: none;
    .file{
      margin-left: 1em;
    }
  }
</style>
