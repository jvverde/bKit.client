<template>
  <div class="main">
    <bkitlogo></bkitlogo>
    <div class="computers" :class="{onlyone:onlyone}">
      <div class="computer" v-for="(computer,index) in computers"
        :class="{selected:computer.selected}" 
        @click.stop="select(index)">
        <div class="name">{{computer.name}}</div>
        <div class="uuid">uuid:{{computer.uuid}}</div>
        <drives :computer="computer" class="components"></drives>
      </div>
    </div>
  </div>
</template>

<script>
  import Drives from './Computers/Drives'

  export default {
    data () {
      return {
        onlyone: false,
        computers: []
      }
    },
    components: {
      Drives
    },
    props: ['name'],
    created () {
      let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/'
      this.$http.jsonp(url + 'computers/').then(
        function (response) {
          this.computers = Object.keys(response.data).map(function (key) {
            let id = response.data[key]
            let uuid = ((id || '').split('.') || []).pop()
            let name = (key.split('.') || []).shift()
            return {name: name, id: id, uuid: uuid}
          }).sort(function (a, b) {
            return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
          })
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      select (index) {
        let computer = this.computers[index]
        if (computer.selected) {
          this.onlyone = computer.selected = false
        } else {
          this.onlyone = computer.selected = true
        }
      }
    }
  }
</script>

<style scoped lang="scss">
  @import "../config.scss";
  .computers{
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    align-items: center;
    width:100%;
    &.onlyone .computer.selected{
      width: 100%;
    }
    &.onlyone .computer:not(.selected){
      width: 0;
      height: 0;
      margin: 0;
      padding: 0;
      border-width: 0;
    }
    .computer{
      width: $rackwidth;
      height: 4*$U; //4U
      overflow: hidden;

      border: 1px solid lightgray;

      transition: all .2s ease-out;

      background: radial-gradient(black 15%, transparent 16%) 0 0, 
        radial-gradient(black 15%, transparent 16%) 4px 4px,
        radial-gradient(rgba(255,255,255,.1) 15%, transparent 20%) 0 1px,
        radial-gradient(rgba(255,255,255,.1) 15%, transparent 20%) 4px 5px
      ;

      background-size:8px 8px;

      background-color:#282828;

      position: relative;

      padding-top: 1.3*$LSIZE;
      padding-left: 1.5*$LSIZE;
      padding-right: $LSIZE;
      padding-bottom: 1.1*$LSIZE;
      margin: 2px 10px; 
      box-sizing: border-box;
      *{
        font-size: 8pt;
        line-height: $LSIZE;
        box-sizing: border-box;
      }
      &:after,&:before{
        content: "\02297";
        font-size: 60%;
        text-align: center;
        position: absolute;
        top: 0;
        height: 100%;
        background-image: radial-gradient(ellipse at center,  #FFF 0%,#DDD 40%,#FFF 100%);
        background-size: 100% 33%;
        z-index: 5;
      }
      &:before{
        left: 0;
      }
      &:after{
        right: 0;
      }
      &:hover:before,&:hover:after{
        content: "O";
      }
      .name, .uuid{
        position: absolute;    
        max-height: $LSIZE;
        background-color: #aaa;
        color: #000;
        padding: 1px 1em;
        z-index: 2;
      }
      .name{
        top: 1px;
        right: 2em;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
        text-align: center;
      }
      .uuid{
        position: absolute;
        bottom: 0;
        left: 0;
        font-size: 6pt;
        line-height: initial;
        &:before{
          content: "ID:"
        }
        border-top-right-radius: 4px;
      }
      .components{
        height: 100%;
        overflow: hidden;
        border:2px solid #555;
        background: radial-gradient(ellipse at center,  #444 0%,#111 90%,#000 100%);  
        background-size: 3px 3px;  

        background-color:#333;
      }
      &:hover{
        transform: scale(1.01,1.01);
        box-shadow: 3px 3px 3px 3px #ccc;
        cursor: pointer;
      }
    }
  }
</style>
