<template>
  <ul class="directories">
    <li v-if="loading">
        <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
    </li>
    <li v-for="(folder,index) in folders" @click.stop="select(folder)">
      <header class="line" :class="{selected:currentPath === folder.location.path}">
        <div class="props">
          <span class="icon is-small" @click.stop="toggle(index)">
            <!-- <i class="fa fa-spinner fa-spin" v-if="isWaiting(index)"></i> -->
            <i class="fa fa-minus-square-o" v-if="folder.open"></i>
            <i class="fa fa-plus-square-o" v-else></i>
          </span>
	        <span class="icon is-small">
            <i class="fa fa-folder-open-o" v-if="folder.open"></i>
            <i class="fa fa-folder-o" v-else></i>
	        </span>
	        <span class="name">{{folder.name}}</span>
        </div>
        <a :href="getUrl('bkit',folder.name)" title="Recovery" @click.stop="" class="links">
          <span class="icon is-small">
            <i class="fa fa-history"></i>
          </span>
        </a>
      </header>
      <directory v-if="folder.open" :location="folder.location" v-on:select="bubbling">
      </directory>
    </li>
  </ul>
</template>

<style scoped lang="scss">
  @import "../../config.scss";
  ul.directories{
    list-style: none;
    position:relative;
    li {
      display: flex;
      flex-direction: column;
      padding-left: $li-ident;            /* indentation = .5em */
      line-height:$line-height;
      cursor: pointer;
      box-sizing: border-box;
      position: relative;
      &::before, &::after {
        border-width: 0;
        border-style: dotted;
        border-color: #777777;
        position:absolute;
        display:block;
        content:"";
        left:$li-ident / 4;
      }
      &::before{
        width: .5 * $li-ident;          /* 50% of indentation */
        height: 0;
        border-top-width:1px;
        margin-top:-1px;
        margin-left: 3px;
        top:$line-height / 2;
      }
      &::after{
        width: 0;
        top: 0;
        bottom: 1px;
        border-left-width:1px;
      }
      &:first-child::after{ // first line must start a little bit closer to the parent
        top: - $line-height / 4;
      }
      &:last-child::after{ // last line should stop at middle
        bottom: auto; //disable bottom
        height: $line-height / 2;
      }
      &:last-child:first-child::after{ //just to correct shift to top on first line
        height: $line-height / 2 + $line-height / 4;
      }
      header.line{
        display: flex;
        width: 100%;
        border-radius:4px;
        .links{
          flex-shrink: 0;
          margin-right: 3px;
          margin-left: 1px;
        }
        .props{
          flex-grow: 1;
          display: flex;
          overflow: hidden;
          .icon{
            padding-right:1px;
            padding-left:1px;
            flex-shrink: 0;
          }
          .file{
            flex-grow: 1;
            display: flex;
            * {
              display: inline-block;
              text-overflow: ellipsis;
              white-space: nowrap;
            }
            .name{
              flex-shrink: 0;
              flex-grow: 1;
              padding-right:3px;
              padding-left:3px;
            }
          }
        }
      }
      header.line.selected{
        background-color: $li-selected;
      }
      header.line:hover{
        background-color: $li-hover;
      }
    }
  }
</style>

<script>
  import Formateddate from './Recovery/Formateddate'
  import Formatedsize from './Recovery/Formatedsize'

  const requiredLocation = {
    type: Object,
    required: true,
    validator: function (obj) {
      return obj.computer && obj.disk && obj.snapshot && obj.path &&
        obj.path.match(/^\//) && obj.path.match(/\/$/)
    }
  }
  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }

  /* import { mapGetters } from 'vuex' */

  export default {
    name: 'directory',
    data () {
      return {
        url: this.$store.getters.url,
        folders: [],
        files: [],
        loading: true
      }
    },
    props: {
      location: requiredLocation
    },
    computed: {
      currentPath () {
        return this.$store.getters.path
      }
    },
    watch: {
      location () {
        this.refresh()
      }
    },
    components: {
      Formateddate,
      Formatedsize
    },
    created () {
      this.refresh()
    },
    methods: {
      getUrl (base, entry) {
        return this.url + base +
          '/' + this.location.computer +
          '/' + this.location.disk +
          '/' + this.location.snapshot +
          this.location.path +
          encodeURIComponent(entry || '')
      },
      toggle (index) {
        this.folders[index].open = !this.folders[index].open
      },
      bubbling (location) {
        this.$emit('select', location)
      },
      select (folder) {
        this.$store.dispatch('setPath', folder.location.path)
        this.bubbling(folder.location)
      },
      refresh () {
        try {
          var url = this.getUrl('folder')
          this.loading = true
          this.$http.jsonp(url).then(
            function (response) {
              let files = (response.data.files || []).sort(order)
              let folders = (response.data.folders || []).map(folder => ({
                name: folder,
                location: Object.assign({}, this.location, {
                  path: this.location.path + encodeURIComponent(folder) + '/'
                }),
                open: (this.folders.find(e => e.name === folder) || {})
                  .open === true
              })).sort(order)
              this.$nextTick(() => {
                this.loading = false
                this.files = files
                this.folders = folders
              })
            },
            function (response) {
              this.loading = false
              console.error(response)
            }
          )
        } catch (e) {
          this.loading = false
          console.error(e)
        }
      }
    }
  }
</script>

