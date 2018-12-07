<template>
  <div class="backup">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <breadcrumb></breadcrumb>
      <div class="accordion">
        <section class="cell" v-for="(snap, index) in snaps"
          @click.stop="select(index)"
          :class="{selected: snap.id === currentSnap}">
          <header class="spine" :title="snap.date.format('DD-MM-YYYY HH:mm')">
            {{snap.date.fromNow(true)}}
          </header>
          <article>
            <time class="day">{{snap.date.format('dddd')}}</time>
            <time class="time">{{snap.date.format('HH:mm')}}</time>
            <time class="date">{{snap.date.format('DD-MM-YYYY')}}</time>
          </article>
        </section>
      </div>
    </header>
    <snapshot v-if="rootLocation.snapshot !== null"
      :rootLocation="rootLocation" class="snapshot">
    </snapshot>
    <footer class="bottom">
      <console></console>
    </footer>
  </div>
</template>

<script>
  import Snapshot from './Backup/Snapshot'
  import Breadcrumb from './Backup/Breadcrumb'
  import Console from './Console'

  var moment = require('moment')
  moment.locale('en')
  moment.relativeTimeThreshold('m', 119)
  moment.relativeTimeThreshold('h', 47)
  moment.relativeTimeThreshold('d', 59)
  moment.relativeTimeThreshold('M', 23)

  export default {
    data () {
      return {
        currentSnap: null,
        snaps: []
      }
    },
    use: {
    },
    filters: {
    },
    computed: {
      currentLocation () {
        return this.$store.getters.location
      },
      rootLocation () {
        return {
          computer: this.$route.params.computer,
          disk: this.$route.params.disk,
          snapshot: this.currentSnap,
          path: '/'
        }
      }
    },
    components: {
      Snapshot,
      Breadcrumb,
      Console
    },
    props: [],
    created () {
      let url = this.$store.getters.url +
        'backup' +
        '/' + this.rootLocation.computer +
        '/' + this.rootLocation.disk
      this.$http.get(url).then(response => {
        this.snaps = (response.data || []).map(snap => {
          return {
            id: snap,
            date: moment.utc(snap.substring(5), 'YYYY.MM.DD-HH.mm.ss').local()
          }
        })
        this.select(this.snaps.length - 1)
      }, response => {
        console.error(response)
      })
    },
    methods: {
      select (index) {
        this.currentSnap = this.snaps[index].id
        this.$store.dispatch('setLocation',
          Object.assign({}, this.currentLocation, {snapshot: this.currentSnap})
        )
      },
      howlong (snap) {
/*        let now = moment()
        let x = snap.date*/
/*        return now.diff(x, 'minutes') < 120 ? now.diff(x, 'minutes') + ' min'
          : now.diff(x, 'hours') < 48 ? now.diff(x, 'hours') + ' hours'
          : now.diff(x, 'days')  < 60 ? now.diff(x, 'days') + ' days'
          : now.diff(x, 'months')  < 60 ? now.diff(x, 'days') + ' days'*/
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
  .backup{
    height:100%;
    width: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    header.top{
      flex-shrink: 0;
      .logo{
        float:left;
      }
    }
    .snapshot{
      flex-grow:1;
      overflow: hidden;
      height: 100%;
    }
    footer.bottom{
      flex-shrink: 0;
      padding-top:1px;
      margin-top: 1px;
      width: 100%;
      max-height: 30%;
      display: flex;
    }
  }

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
      margin: 2px;
      width: 3em;
      min-width: 1em;
      height:$aheight;
      padding: 1px;
      transition:min-width .2s ease-out;
      position: relative;
      font-size: 8pt;
      header{
        white-space: nowrap;
        text-overflow: ellipsis;
        width: $aheight;
        line-height: 1em;
        text-align: left;
        vertical-align: middle;
        padding:0;
        left:-$aheight/2;
        top: $aheight/2;
        margin-left: 50%;
        font-weight: normal;
        display:block;
        position:absolute;
        transform: rotate(90deg);
        transform-origin: 50% 50%;
      }
      article{
        //https://www.sitepoint.com/create-calendar-icon-html5-css3/
        margin:0;
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
        top: 110%;
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
          opacity: 0;
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
