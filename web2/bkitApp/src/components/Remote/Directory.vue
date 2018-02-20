<template>
  <ul class="directories">
    <li v-if="loading">
        <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
    </li>
    <li v-for="(dir,index) in dirs"
      :key="index"
      @click.stop="select(dir)">
      <header class="line" :class="{selected:currentPath === dir.location.path}">
        <div class="props">
          <span class="icon is-small">
            <i class="fa fa-minus-square-o close"
              v-if="dir.open"
              @click.stop="dir.open=false">
            </i>
            <i class="fa fa-plus-square-o open"
              v-else
              @click.stop="dir.open=true">
            </i>
          </span>
          <span class="icon is-small">
            <i class="fa fa-dir-open-o" v-if="dir.open"></i>
            <i class="fa fa-dir-o" v-else></i>
          </span>
          <span class="name">{{dir.name}}</span>
        </div>
        <a :href="getUrl('bkit',dir.name)" title="Recovery"
          @click.stop class="links">
          <span class="icon is-small">
            <i class="fa fa-history"></i>
          </span>
        </a>
      </header>
      <directory v-if="dir.open" :location="dir.location"/>
    </li>
  </ul>
</template>

<script>
import axios from 'axios'
import { mapGetters, mapMutations } from 'vuex'
import {myMixin} from 'src/mixins'

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

export default {
  name: 'directory',
  data () {
    return {
      dirs: [],
      loading: true
    }
  },
  props: {
    location: requiredLocation
  },
  mixins: [myMixin],
  computed: {
    ...mapGetters('location', ['getLocation']),
    currentPath () {
      return this.getLocation.path
    }
  },
  watch: {
    location () {
      this.refresh()
    }
  },
  components: {
  },
  mounted () {
    this.refresh()
  },
  methods: {
    ...mapMutations('location', ['setLocation']),
    getUrl (base, entry) {
      return base +
        '/' + this.location.computer +
        '/' + this.location.disk +
        '/' + this.location.snapshot +
        this.location.path +
        encodeURIComponent(entry || '')
    },
    select (dir) {
      this.setLocation(dir.location)
      dir.open = !dir.open
    },
    refresh () {
      // client/disk/#disk/snap/#snap
      const url = `/auth/client/${this.location.computer}/disk/${this.location.disk}/snap/${this.location.snapshot}/dirs${this.location.path}`
      // const url = this.getUrl('/auth/client/dirs')
      this.loading = true
      axios.get(url)
        .then(response => {
          let dirs = (response.data || []).map(dir => ({
            name: dir,
            location: Object.assign({}, this.location, {
              path: this.location.path + encodeURIComponent(dir) + '/'
            }),
            open: (this.dirs.find(e => e.name === dir) || {})
              .open === true
          })).sort(order)
          this.$nextTick(() => {
            this.loading = false
            this.dirs = dirs
          })
        })
        .catch(err => {
          this.loading = false
          this.catch(err)
        })
    }
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/config.scss";
  ul.directories{
    list-style: none;
    position:relative;
    padding: 0px;
    li {
      display: flex;
      flex-direction: column;
      line-height:$line-height;
      box-sizing: border-box;
      position: relative;
      &>*{
        padding-left: $li-ident;            /* indentation = .5em */
      }
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
      li:first-child::after{ // first line must start a little bit closer to the parent, except the top one
        top: - $line-height / 4;
      }
      &:last-child::after{ // last line should stop at middle
        bottom: auto; //disable bottom
        height: $line-height / 2;
      }
      li:last-child:first-child::after{ //just to correct shift to top on first line
        height: $line-height / 2 + $line-height / 4;
      }
      header.line{
        display: flex;
        width: 100%;
        border-radius:4px;
        cursor: pointer;
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
          .open{
            cursor:zoom-in
          }
          .close{
            cursor: zoom-out
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
