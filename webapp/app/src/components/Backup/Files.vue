<template>
  <ul class="files">
    <li v-for="file in files">
      <div class="props">
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
        files: []
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
      refresh () {
        try {
          const url = this.getUrl('folder')
          this.$http.jsonp(url).then((response) => {
            let files = (response.data.files || []).sort(order)
            this.$nextTick(() => {
              this.files = files
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

