<template>
  <div class="drives">
    <div class="drive"
      v-for="(drive, index) in drives"
      :key="index">
      <router-link :to="{
        name: 'Backups',
        params: {
          computer: computer.id,
          disk:drive.id
        }
      }" class="link">
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
import axios from 'axios'
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
    axios.get(`/auth/client/${this.computer.id}/disks/`)
      .then((response) => {
        this.drives = response.data.map((disk) => {
          const comps = disk.split('.') || []
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
      }).catch(this.catch)
  },
  methods: {
    toggle_drive (index) {
      this.drives[index].open = !this.drives[index].open
    }
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/config.scss";
  $margin: $scale * .05in;
  $width: $scale * 1.5in;
  .drives{
    display: flex;
    flex-wrap: nowrap;
    justify-content: flex-end;
    align-items: center;
    .drive{
      height: 100%;
      margin: $margin;
      padding-top: 3px;
      width: $width;
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
      .link {
        text-decoration: none;
        color: inherit;
        width: 100%;
        height: 100%;
        display:block;
        text-align: center;
        &:hover{
          color: green;
        }
      }
      .help {
        display: none;
        position:absolute;
        right: 1px;
        top:1.5em;
        z-index: 50000;
        flex-direction: column;
        justify-content: flex-end;
        align-items: flex-start;
        font-size: 8pt;
        background-color: #EEE;
        background-color: rgba(240,240,240,0.7);
        border-radius: 5px;
        padding: 5px;
        span{
          text-overflow: ellipsis;
          white-space: nowrap;
          overflow: hidden;
          text-align: left;
          color: black;
        }
      }

      &:hover>.help {
        display: flex;
      }

      $limit: 50;
      $i: 1;
      @while $i<$limit {
        $v: 100%-$i*100%;
        &:nth-last-child(#{$i})>.help {
          left: auto;
          right: $v;
        }
        // para a primeira metade dos discos, mas só se hover mais de 10 discos
        &:nth-child(#{$i}):not(:nth-last-child(-n+#{$i})):not(
          :nth-last-child(-n+5))>.help {
          right: auto;
          left: $v;
        }
        $i:$i + 1;
      }
    }
  }
</style>
