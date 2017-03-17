<template>
  <div class="home">
    <bkitlogo class="logo"></bkitlogo>
    <h1>bKit Home</h1>
    <section>
      <router-link v-for="link in links"
        :to="link.ref" class="link" 
        :style="{width:width, height:height}">
        {{link.name}}
      </router-link>
    </section>
  </div>
</template>

<script>
export default {
  name: 'home',
  data () {
    return {
      links: [
        {name: 'Backup', ref: '/local/disks'},
        {name: 'Recovery', ref: '/computers'},
        {name: 'Server', ref: '/server'},
        {name: 'Init', ref: '/init'},
        {name: 'Update', ref: '/update'}
      ]
    }
  },
  computed: {
    sqrt () {
      return Math.ceil(Math.sqrt(this.links.length || 0)) || 1
    },
    width () {
      const p = 0 | 90 / this.sqrt
      return `${p}vw`
    },
    height () {
      const p = 0 | 50 / this.sqrt
      return `${p}vh`
    }
  },
  methods: {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  @import "../config.scss";
  .home{
    display: flex;
    flex-direction: column;
    flex-grow:1;
    h1{
      overflow: hidden;
      flex-shrink:10000;
    }
    section{
      flex-grow:1;
      display: flex;
      flex-wrap: wrap;
      justify-content: center; 
      align-content: center;
      overflow: auto;
      .link {
        display:flex;
        align-items: center; 
        justify-content: center; 
        min-height: 3em;
        border-radius: 20px;
        border: 1px solid $bkit-color;
        margin: 1px;
      }
      .link:hover{
        background-color: $li-hover;
      }
    }
  }
</style>
