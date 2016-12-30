<template>
  <div class="backup">
    <!--<icon name="clone" scale=".9"></icon>-->
    {{location.backup}}
    {{location.computer}}
    {{location.disk}}
<!--     <directory v-if="open"
      :entries="entries"
      path="/"
      :location="location">
    </directory> -->
    <div class="accordion">
      <section class="cell" v-for="(snap, index) in snaps" @click.stop="selectedCell = index"
        :class="{selected: index === selectedCell}">
        <header class="spine">{{snap.date.fromNow(true)}}<!-- {{bak.time.local().fromNow(true)}} --></header>
        <article>
          <time class="day"><!-- {{bak.time.local().format('dddd')}} --></time>
          <time class="time"><!-- {{bak.time.local().format('HH:mm')}} --></time>
          <time class="date"><!-- {{bak.time.local().format('DD-MM-YYYY')}} --></time>
        </article>
      </section>
    </div>
  </div>
</template>

<script>
  // import Directory from './Directory'
  var moment = require('moment')
  moment.locale('pt')
  console.log(moment().format('dddd, MMMM Do YYYY, h:mm:ss a'))

  export default {
    data () {
      return {
        selectedCell: -1,
        snaps: [],
        location: {}
      }
    },
    use: {
    },
    filters: {
      momento: function (v, f) {
        return v.format(f)
      }
    },
    components: {
      // Directory
    },
    props: [],
    mounted () {
      this.location = {
        computer: this.$route.params.computer,
        disk: this.$route.params.disk
      }
      let url = 'http://' + this.$electron.remote.getGlobal('server').address + ':' + this.$electron.remote.getGlobal('server').port + '/' +
        'backup' +
        '/' + this.location.computer +
        '/' + this.location.disk
      this.$http.jsonp(url).then(
        function (response) {
          console.log(response.data)
          // this.$set('snaps', response.data)
          this.snaps = (response.data || []).map(function (snap) {
            // console.log('+++++++')
            // console.log(snap)
            let date = moment.utc(snap.substring(5), 'YYYY.MM.DD-HH.mm.ss')
            // console.log(date.format())
            // date.local()
            // console.log(date.format())
            // console.log('---------')
            return {id: snap, date: date.local()}
          })
        },
        function (response) {
          console.error(response)
        }
      )
    },
    methods: {
      toggle () {
        this.open = !this.open
      }
    }
  }
</script>

<style scoped lang="scss">
  $height: 6em;
  $width: 10em;
  $bgcolor:lightgray;
  $hvcolor: rgba(230, 230, 230, 0.9);
  $aheight: $width*.7;

  .accordion {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    overflow:hidden;
    overflow-x:auto; 
    margin:5px 2px 5px 20px;
    color:#474747;
    background:#eee;
    padding:1px 3px; 
    border-radius: 5px;
    border:2px solid #ccc; 
    section{
      overflow:hidden;
      cursor:pointer;
      background: $bgcolor;
      border-radius: 4px;
      margin:2px;
      width:3em;
      min-width: .5em;
      height:$aheight;
      padding:1px; 
      transition:min-width .2s ease-out;
      header{
        white-space: nowrap;
        text-overflow: ellipsis;
        width: $aheight;
        line-height: 3em;
        top: -3em;
        text-align: center;
        vertical-align: middle;
        padding:0;
        font-size: 1em;
        font-weight: normal;
        display:block; 
        position:relative; 
        transform: rotate(90deg);
        transform-origin: left bottom;
      }
      article{
        //https://www.sitepoint.com/create-calendar-icon-html5-css3/
        margin:0; 
        font-size: 1em; /* change size */
        display: flex;
        justify-content: center;
        align-items:center;
        position: relative;
        background-color: #c8c8c8;
        border-radius: 5px;
        box-shadow: 1px 1px 0 #666, 2px 2px 0 #666, 3px 3px 0 #666, 3px 4px 0 #666, 3px 5px 0 #666, 0 0 0 2px #bbb;
        overflow: hidden;        
        width: 0;
        height: 0;
        top: 100%;
        transition:top .5s linear;
        transition-delay: .2s;
        time{
          display: block;
          width: 100%;
          font-size: 1em;
          font-weight: bold;
          font-style: normal;
          text-align: center;
          &.day{
            position: absolute;
            top: 0;
            left:0;
            padding: 0.2em 0;
            color: #fff;
            background-color: #67a9fb;
            border-bottom: 1px dashed #f37302;
            box-shadow: 0 2px 0 #67a9fb;
          }
          &.time{
            letter-spacing: -0.05em;
            color: #2f2f2f;
            position: relative;
            padding: 0.5em 0;
            &:before,&:after{
              content: "";
              display: block;
              position: absolute;
              bottom: 0em;
              width:1.5em;
              height:1.5em;
              border-radius:500px;
              border:2px dashed #bbb;
              background-color: #eee;
            }
            &:after {
              right:0.5em;
            }
            &:before{
              left:0.5em;
            }
          }
          &.date{
            position: absolute;
            bottom: 0.3em;
            left:0;
            color: #2f2f2f;
          }
        }
      } 
      &:hover {
        background:$hvcolor;
      }
      &.selected{
        background:#eee; 
        padding:0.5em 1em;
        width: auto;
        min-width: $width + 2;
        header{
          width:0;
          height:0;
        }
        article{
          width: $width;
          height: $height;
          top:0;
        }
      }
    }
  }

</style>
