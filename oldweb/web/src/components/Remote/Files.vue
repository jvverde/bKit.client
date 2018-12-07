<template>
  <ul class="files">
    <li v-for="file in files">
      <div class="props" :class="{deleted:file.deleted, changed:file.changed}">
        <span class="icon is-small">
          <i class="fa fa-file-o"></i>
        </span>
        <a :download="file" class="file" @click.stop=""
          :href="getFullUrl('download',file.name)">
          <span class="name">{{file.name}}</span>
          <formatedsize :value="file.size"></formatedsize>
          <formateddate :value="file.datetime"></formateddate>
        </a>
      </div>
      <div class="links">
        <a :download="file" @click.stop=""
          :href="getFullUrl('download',file.name)" title="Download">
          <span class="icon is-small">
            <i class="fa fa-download"></i>
          </span>
        </a>
        <a target="_blank" @click.stop=""
          :href="getFullUrl('view',file.name)" title="View">
          <span class="icon is-small">
            <i class="fa fa-eye"></i>
          </span>
        </a>
        <a :href="getFullUrl('bkit',file.name)" title="Recovery" 
          @click.stop="">
          <span class="icon is-small">
            <i class="fa fa-history"></i>
          </span>
        </a>
      </div>
    </li>
  </ul>
</template>

<script>
  import axios from 'axios'
  import {myMixin} from 'src/mixins'
  import { mapGetters } from 'vuex'

  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }
  export default {
    name: 'files',
    data () {
      return {
        files: [],
        oldlocation: {},
        newestsnap: ''
      }
    },
    props: {
      location: {
        type: Object,
        required: true,
        validator: function (obj) {
          return obj.computer && obj.disk && obj.snapshot && obj.path &&
            obj.path.match(/^\//) && obj.path.match(/\/$/)
        }
      }
    },
    watch: {
      location () {
        this.refresh()
      }
    },
    mounted () {
      this.refresh()
    },
    computed: {
      ...mapGetters('auth', ['baseURL', 'token'])
    },
    mixins: [myMixin],
    methods: {
      getUrl (type, entry) {
        return `/auth/client/${this.location.computer}/disk/${this.location.disk}/snap/${this.location.snapshot}/${type}${this.location.path}` +
          encodeURIComponent(entry || '')
      },
      getFullUrl (type, entry) {
        const r = this.getUrl(type, entry)
        return `${this.baseURL}${r}?access_token=${this.token}`
      },
      isSnap () {
        return this.location.path === this.oldlocation.path &&
          this.location.computer === this.oldlocation.computer &&
          this.location.disk === this.oldlocation.disk &&
          this.location.snapshot !== this.oldlocation.snapshot
      },
      refresh () {
        const url = this.getUrl('files')
        axios.get(url).then(response => {
          let files = (response.data || []).sort(order)
          if (this.isSnap()) {
            if (this.location.snapshot > this.newestsnap) {
              this.newestsnap = this.location.snapshot
              this.newestfiles = files
              // console.log('New snapshot', this.newestsnap)
            } else { // old snapshot in same path
              // console.log('compare files')
              files.forEach(f => {
                const old = this.newestfiles.find(e => {
                  return e.name === f.name
                })
                if (!old) {
                  // console.log('Not found', f.name)
                  f.deleted = true
                } else if (old.size !== f.size ||
                    old.datetime !== f.datetime) {
                  // console.log('Different size for', f.name)
                  f.changed = true
                }
              })
            }
          } else { // new path
            this.newestfiles = files
            this.newestsnap = this.location.snapshot
            // console.log('new path and new snapshot', this.newestsnap)
          }
          this.$nextTick(() => { // update on next clock ticket
            this.files = files
            this.oldlocation = this.location
          })
        }).catch(this.catch)
      }
    }
  }
</script>

<style scoped lang="scss">
  @import "~scss/config.scss";
  ul.files {
    list-style: none;
    overflow: auto;
    li:hover{
      background:#eeeeee;
      background-color: $li-hover;
      border-radius:6px;
    }
    li {
      cursor: pointer;
      display: flex;
      padding-left: 2px;
      line-height:$line-height;
      padding-right: 1em;
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
      .props.deleted{
        color:red;
      }
      .props.changed{
        color: blue;
      }
    }
  }
</style>
