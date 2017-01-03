<template>
  <div class="drives">
    <div class="drive" v-for="(drive, index) in drives">
        <router-link :to="{name: 'Backups-page', params: {
            computer: computer.id,
            disk:drive.id 
        }}">
          {{drive.name}}
        </router-link>
<!--       <ul v-if="drive.open">
        <backup v-for="backup in drive.backups"
          :location="{computer:this.computer.id, drive:drive.id, backup:backup}">
        </backup>  -->
      </ul>
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
          console.log(response.data)
          this.drives = response.data.map(function (disk) {
            let name = (disk.split('.') || []).shift()
            return {name: name, id: disk}
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
      color: #fff;
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
    }
  }
</style>
