<template>
  <ul class="files">
    <li v-for="file in files">
      <div class="props" :class="{deleted:file.deleted, changed:file.changed}">
        <span class="icon is-small">
          <i class="fa fa-file-o"></i>
        </span>
        <a :download="file" class="file" @click.stop=""
          :href="getUrl('download',file.name)">
          <span class="name">{{file.name}}</span>
          <formatedsize :value="file.size"></formatedsize>
          <formateddate :value="file.datetime"></formateddate>
        </a>
      </div>
      <div class="links">
        <a :download="file" @click.stop=""
          :href="getUrl('download',file.name)" title="Download">
          <span class="icon is-small">
            <i class="fa fa-download"></i>
          </span>
        </a>
        <a target="_blank" @click.stop=""
          :href="getUrl('view',file.name)" title="View">
          <span class="icon is-small">
            <i class="fa fa-eye"></i>
          </span>
        </a>
        <a :href="getUrl('bkit',file.name)" title="Recovery" @click.stop="">
          <span class="icon is-small">
            <i class="fa fa-history"></i>
          </span>
        </a>
      </div>
    </li>
  </ul>
</template>

<style scoped lang="scss">
  @import "../../config.scss";
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

<script>
  import Formateddate from './Recovery/Formateddate'
  import Formatedsize from './Recovery/Formatedsize'
  function order (a, b) {
    return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
  }
  export default {
    name: 'files',
    data () {
      return {
        url: this.$store.getters.url,
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
    components: {
      Formateddate,
      Formatedsize
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
      isSnap () {
        return this.location.path === this.oldlocation.path &&
          this.location.computer === this.oldlocation.computer &&
          this.location.disk === this.oldlocation.disk &&
          this.location.snapshot !== this.oldlocation.snapshot
      },
      refresh () {
        try {
          const url = this.getUrl('folder')
          this.$http.jsonp(url).then((response) => {
            let files = (response.data.files || []).sort(order)
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
          }, (error) => {
            console.error(error)
          })
        } catch (e) {
          console.error(e)
        }
      }
    }
  }
</script>

