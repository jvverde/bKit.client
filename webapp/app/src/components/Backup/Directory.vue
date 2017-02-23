<template>
  <div class="tree">
    <ul class="directories" v-if="folders.length > 0">
      <li v-for="(folder,index) in folders" @click.stop="toggle(index)">
        <div class="line">
	        <div class="props">
            <span class="icon is-small">
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
        </div>
        <directory v-if="folder.open" :location="folder.childrensLocation">
        </directory>
      </li>
    </ul>
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
  </div>
</template>

<style scoped lang="scss">
  $line-height: 2em;
  $li-ident: 1.3em;
  .tree{
    text-align: left;
    width:100%;
    height: 100%;

    ul,li{
      padding: 0;
      margin: 0;
      list-style: none;
      position:relative;
      &::before{
        border-width: 0;
        border-style: dotted;
        border-color: #777777;
        position:absolute;
        display:block;
        content:"";
      }
    }
    ul::before {
        content:"";
        top:-1 * ($line-height / 2);
        bottom: $line-height / 2;      /*stop at half of last li */
        left: $li-ident / 4;
        border-left-width:1px;
    }
    .line + .tree {                   /*in first subtree the border-left start on .6 * top */
      overflow: visible;
      ul:first-child{
        overflow: visible;
        &::before{
          top:-.6 * ($line-height / 2);
        }
      }
    }
    ul.directories + ul.files {     /*in first file, after directores, the border-left should be visible outside*/
      overflow: visible;
    }
    ul.files li, ul.directories .line{
      display:flex;
      &:hover{
        background:#eeeeee;
        background-color:rgba(128,128,128,.2);
        border-radius:6px;
      }
    }
    li {
      padding-left: $li-ident;            /* indentation = .5em */
      line-height:$line-height;
      cursor: pointer;
      width:100%;
      box-sizing: border-box;
      &::before {
        width: .5 * $li-ident;          /* 50% of indentation */
        height:0;
        border-top-width:1px;
        margin-top:-1px;                  /* border top width */
        top:$line-height / 2;
        left:$li-ident / 4;
      }
      a{
        color: inherit;
        .icon:hover{
          color: #090;
        }
        &:active{
          border:1px solid red;
        }
      }
      * {
        flex-grow: 0;
        overflow: hidden;
      }
      .props{
        flex-grow:2;
        display: flex;
        .file{
          flex-grow:2;
          display: flex;
          .name{
            flex-grow:2;
            flex-shrink: 0;
            display: inline-block;
            text-overflow: ellipsis;
            white-space: nowrap;
            padding-right:3px;
            padding-left:3px;
          }
        }
        .icon{
          padding-right:1px;
          padding-left:1px;
        }
      }
      .links{
        flex-shrink: 0;
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
        files: []
      }
    },
    props: {
      location: requiredLocation
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
      refresh () {
        try {
          var url = this.getUrl('folder')
          this.$http.jsonp(url).then(
            function (response) {
              let files = (response.data.files || []).sort(order)
              let folders = (response.data.folders || []).map(folder => ({
                name: folder,
                childrensLocation: Object.assign({}, this.location, {
                  path: this.location.path + encodeURIComponent(folder) + '/'
                }),
                open: (this.folders.find(e => e.name === folder) || {})
                  .open === true
              })).sort(order)
              this.$set(this, 'files', files)
              this.$set(this, 'folders', folders)
            },
            function (response) {
              console.error(response)
            }
          )
        } catch (e) {
          console.error(e)
        }
      }
    }
  }
</script>

