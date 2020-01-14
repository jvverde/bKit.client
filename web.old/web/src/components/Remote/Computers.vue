<template>
  <div class="contentor no-wrap">
    <div class="computers" :class="{onlyone:onlyone}">
      <i v-if="computers.length === 0" class="fa fa-spinner fa-spin fa-5x fa-fw"></i>
      <div class="computer" v-for="(computer,index) in computers"
        :class="{selected:computer.selected, myself:computer.myself}"
        @click.stop="select(index)">
        <div class="name">{{computer.name}}</div>
        <div class="uuid">uuid:{{computer.uuid}}</div>
        <drives :computer="computer" class="components"/>
      </div>
    </div>
  </div>
</template>

<script>
  import Drives from './Drives'
  import {
    QIcon
  } from 'quasar'
  import axios from 'axios'
  import {myMixin} from 'src/mixins'

  export default {
    data () {
      return {
        onlyone: false,
        computers: []
      }
    },
    computed: {
    },
    components: {
      QIcon,
      Drives
    },
    props: ['selected'],
    mixins: [myMixin],
    created () {
      const myself = {id: null}
      axios.get('/auth/clients').then(response => {
        console.log(response.data)
        this.computers = response.data.map((e) => {
          const id = `${e.domain}/${e.name}/${e.uuid}`
          if (id === this.selected) this.onlyone = e.selected = true
          return Object.assign({id: id, myself: id === myself.id}, e)
        }).sort(function (a, b) {
          return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)
        })
      }).catch(this.catch)
    },
    methods: {
      select (index) {
        const computer = this.computers[index]
        this.onlyone = computer.selected = !computer.selected
      }
    }
  }
</script>

<style scoped lang="scss">
  @import "~scss/config.scss";
  @import "~scss/breadcrumb.scss";
  
  .contentor {
    height: 100%;
    width: 100%;
    overflow: hidden;
    overflow-y:auto; 
  }

  header.top{
    flex-shrink:0;
    width: 100%;
    align-self:flex-start;
    .logo{
      float:left;
    }
  }
  .computers{
    display: flex;
    flex-wrap: wrap;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    align-content: space-around;
    width:100%;
    height: 100%;
    overflow: auto;
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
      &:after, &:before{
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
      &.myself .name{
        color:#006400; /* dark geeen x11 */
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
        // transform: scale(1.01,1.01);
        // box-shadow: 3px 3px 3px 3px #ccc;
        cursor: pointer;
      }
    }
  }
</style>
