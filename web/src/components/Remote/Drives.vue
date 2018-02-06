<template>
  <div class="drives">
    <div class="drive" v-for="(drive, index) in drives"
      @mouseout="mouseout"
      @mouseover="mouseover(drive)" >
      <router-link :to="{
        name: 'Backups-page',
        params: {
          computer: computer.id,
          disk:drive.id
        }
      }" class="link">
        {{drive.name}}
      </router-link>
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
      axios.get('/auth/client/disks/' + this.computer.id)
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
      },
      mouseover (disk) {
        this.$emit('overdrive', disk)
      },
      mouseout () {
        this.$emit('outdrive')
      }
    }
  }
</script>

<style scoped lang="scss">
  @import "~scss/config.scss";
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
