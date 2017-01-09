<template>
  <div class="tree">
    <ul class="directories" v-if="folders.length > 0">
      <li v-for="(folder,index) in folders" @click.stop="toggle(index)">
        <div class="line">
	        <div>
            <span class="icon is-small">
              <!-- <i class="fa fa-spinner fa-spin" v-if="isWaiting(index)"></i> -->
              <i class="fa fa-minus-square-o" v-if="folder.open"></i>
              <i class="fa fa-plus-square-o" v-else></i>
            </span>
		        <span class="icon is-small">
              <i class="fa fa-folder-open-o" v-if="folder.open"></i>  
              <i class="fa fa-folder-o" v-else></i>  
		        </span>
		        <span class="text">{{folder.name}}</span>
	        </div>
<!-- 	        <a @click.stop=""
	          :href="getUrl('bkit',folder.name)" title="Recuperar">
            <span class="icon is-small">
              <i class="fa fa-history"></i>  
            </span>
	        </a> -->
          <recovery :url="getUrl('bkit',folder.name)"></recovery>
        </div>
        <directory v-if="folder.open" :location="folder.childrensLocation">
        </directory>
      </li>
    </ul>
    <ul class="files">
      <li v-for="file in files">
        <div class="line">
	        <div class="props">
            <span class="icon is-small">
              <i class="fa fa-file-o"></i>
            </span>
		        <a :download="file" class="file" @click.stop=""
		          :href="getUrl('download',file.name)">
              <span class="text name">{{file.name}}</span>
              <span>
                <formatedsize :value="file.size"></formatedsize>
                <formateddate :value="file.datetime"></formateddate>
              </span>
		        </a>
	        </div>
	        <div>
		        <a :download="file" @click.stop=""
		          :href="getUrl('download',file.name)" title="Download">
              <span class="icon is-small">
                <i class="fa fa-download"></i>  
              </span>
		        </a>        
		        <a target="_blank" @click.stop=""
		          :href="getUrl('view',file.name)" title="Ver">
              <span class="icon is-small">
                <i class="fa fa-eye"></i>  
              </span>
		        </a>
<!-- 		        <a @click.stop=""
		          :href="getUrl('bkit',file)" title="Recuperar">
              <span class="icon is-small">
                <i class="fa fa-history"></i>  
              </span>
		        </a> -->
            <recovery :url="getUrl('bkit',file.name)"></recovery>
	        </div>
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
    ul{
      &::before {
        content:"";
        top:-.3 * ($line-height / 2);
        bottom:$line-height / 2;      /*stop at half of last li */
        left: $li-ident / 4;
        border-left-width:1px;
      }
    }
    ul.directories + ul.files::before {
      top:-1 * ($line-height / 2);  
    }
    li {
      padding-left: $li-ident;            /* indentation = .5em */
      line-height:$line-height;  
      cursor: pointer;
      &::before {
        width: .5 * $li-ident;          /* 50% of indentation */
        height:0;
        border-top-width:1px;
        margin-top:-1px;                  /* border top width */
        top:$line-height / 2;              
        left:$li-ident / 4;
      }
      div.line {
        width:100%;
        box-sizing: border-box;
        display:flex;
        flex-wrap:nowrap;
        justify-content:space-between;
        &:hover{
             background:#eeeeee;
             border-radius:7px;
             padding-right:1px;
             padding-left:1px;
        }
        *{
          display:flex;
          flex-wrap:nowrap;
          align-items: center;
          &:not(:first-child):not(a){
            padding-left: 4px;
          }
        } 
        .text{
          text-overflow: ellipsis;
          white-space: nowrap;
          overflow: hidden; 
        }
        a{
          padding-left:5px;
          color: inherit;
          .icon:hover{
            color: #090;
          }
          &:active{
            border:1px solid red;
          }
        }
        .props{
          display: flex;
          justify-content:space-between;
          flex-grow:2;
          a{
            flex-grow:2;
            display: flex;
            justify-content:space-between;
          }
        }
      }
    }
  }
</style>

<script>
  import Recovery from './Recovery/Recovery'
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
      Recovery,
      Formateddate,
      Formatedsize
    },
    created () {
      console.log('created dir for', this.location.path)
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
          console.log('refresh directory', this.location.path)
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

