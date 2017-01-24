<template>
  <div class="drives">
    <div class="drive" v-for="(drive, index) in drives">
      <router-link :to="{name: 'Backups-page', params: {
          computer: computer.id,
          disk:drive.id
      }}" class="link">
        {{drive.name}}
      </router-link>
      <div class="help">
        <span>Label: {{drive.label}}</span>
        <span>FS: {{drive.fs}}</span>
        <span>Type: {{drive.type}}</span>
        <span>ID: {{drive.uuid}}</span>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data () {
      return {
        drives: []
      }
    },
    components: {
    },
    props: ['computer'],
    created () {
      let url = this.$store.getters.url
      this.$http.jsonp(url + 'disks/' + this.computer.id).then(
        function (response) {
          this.drives = response.data.map(function (disk) {
            let comps = disk.split('.') || []
            return {
              name: comps[0],
              uuid: comps[1],
              label: comps[2],
              type: comps[3],
              fs: comps[4],
              id: disk
            }
          }).sort(function (a, b) {
            return (a.name > b.name) ? -1 : ((b.name > a.name) ? 1 : 0)
          })
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      toggle_drive (index) {
        this.drives[index].open = !this.drives[index].open
      }
    }
  }
</script>

<style scoped lang="scss">
  @import "../../config.scss";
  .drives{
    display: flex;
    flex-wrap: nowrap;
    justify-content: flex-end;
    align-items: center;
    .drive{
      height: 100%;
      margin: 0.5px;
      padding-top: 3px;
      width: $scale * 1.5in;
      background-color: #333;
      border: 1px solid black;
      color: #CCC;
      position: relative;
      &:before{
        content: "";
        position: absolute;
        bottom:3px;
        left:50%;
        width: 0;
        height: 0;
        border-radius: 50px;
        border:2px solid green;
        margin-left: -2px;
      }
      .help{
        display: none;
        position: absolute;
        right: 1px;
        bottom: 1px;
        z-index: 5;
        max-width:12em;
        font-size: 8pt;
        background-color: #999;
        background-color: rgba(128,128,128,0.3);
        border-radius: 5px;
        padding: 2px;
        span{
          text-overflow: ellipsis;
          white-space: nowrap;
          overflow: hidden;
          text-align: left;
        }
      }
      &:hover .help{
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        align-items: flex-start;
      }
      .link {
        text-decoration: none;
        color: inherit;
        width: 100%;
        height: 100%;
        display:block;
        &:hover{
          color: #CCC;
          background-color: rgba(128,128,128,0.5);
        }
      }
    }
  }
</style>
