<template>
  <ul class="breadcrumb">
    <li>
      <span>
       <router-link to="/" class="icon is-small"><i class="fa fa-home"></i></router-link>
      </span>
    </li>
    <li>
      <span>
        <router-link to="/computers" class="icon is-small"><i class="fa fa-desktop"></i> {{computerName}}</router-link>
      </span>
    </li>
    <li>
      <span>
        <router-link :to="{
          name: 'Backups-page',
          params: {
            computer: computer,
            disk:disk
          }}"  class="icon is-small">
          <i class="fa fa-hdd-o"></i> {{diskName}}
        </router-link>
      </span>
    </li>
    <li>
      <span>
        <a class="icon is-small" @click.stop="selectPath('/')">
          <i class="fa fa-calendar"></i> {{snapDate}}
        </a>
      </span>
    </li>
    <li v-for="step in steps">
      <span>
        <a @click.stop="selectPath(step.path)">{{step.value}}</a>
      </span>
    </li>
  </ul>
</template>

<script>
  var moment = require('moment')
  moment.locale('pt')

  export default {
    name: 'breadcrumb',
    data () {
      return {
      }
    },
    computed: {
      computerName () {
        return this.computer.split('.').reverse()[1]
      },
      diskName () {
        const comps = this.disk.split('.')
        comps[0] = comps[0] === '_' ? '' : `${comps[0]}:`
        comps[2] = comps[2] === '_' ? '' : `(${comps[2]})`
        return `${comps[0]} ${comps[2]} `
      },
      snapDate () {
        return moment.utc(this.snap.substring(5), 'YYYY.MM.DD-HH.mm.ss').local().format('DD-MM-YYYY HH:mm')
      },
      currentLocation () {
        return this.$store.getters.location
      },
      steps () {
        const steps = (this.currentLocation.path || '').split('/')
        steps.shift()
        let fullpath = '/'
        const obj = steps.map(e => {
          fullpath += e + '/'
          return {value: e, path: fullpath}
        })
        return obj
      }
    },
    props: ['computer', 'disk', 'snap'],
    components: {
    },
    created: function () {
    },
    methods: {
      selectPath (path) {
        this.$store.dispatch('setLocation',
          Object.assign({}, this.currentLocation, {path: path})
        )
      }
    }
  }
</script>

<style scoped lang="scss">
  $arrowidth: 1em;
  $arrowstrech:2;
  $arrowcolor:lightgray;
  $arrowcolorhover: rgba(230, 230, 230, 0.9);
  $arrowborderradius: 4px;

  ul.breadcrumb {
    list-style: none;
    margin-left: $arrowidth;
    display: flex;
    flex-wrap:wrap;
    font-size: 8pt;
    li {
      border-left: 1px solid transparent;
      display: block;
      margin-top:1px;
      margin-left: -$arrowidth;
      overflow: hidden;
      span {
        padding-left: $arrowidth;
        padding-right: $arrowidth;
        position: relative;
        >*{
          padding-bottom: 5px;
          padding-top: 5px;
          padding-left: .5em;
          white-space: nowrap;
          text-overflow: ellipsis;
          color: inherit;
          display: inline-block;
          background-color: $arrowcolor;
        }
        a{
          text-decoration: none;
          cursor: pointer;
        }
        &:after,&:before {
          content: "";
          display: block;
          width: 0;
          height: 0;
          border-top: $arrowstrech*$arrowidth solid transparent;
          /* Go big on the size, and let overflow hide */
          border-bottom: $arrowstrech*$arrowidth solid transparent;
          border-left: $arrowidth solid $arrowcolor;
          position: absolute;
          top: 50%;
          margin-top: -$arrowstrech*$arrowidth;
          z-index: 2;
        }
        &:after{
          right: 0;
        }
        &:before {
          left: 0;
          border-color: $arrowcolor;
          border-left-color: transparent;
          z-index: 1;
        }
        &:hover{
          &:before{
            border-color: $arrowcolorhover;
            border-left-color: transparent;
          }
          &:after{
            border-left-color: $arrowcolorhover;
          }
          a{
            background-color: $arrowcolorhover;
          }
        }
      }
    }
    li:last-child{
      padding-right: 1em;
      :hover, span * {
        background-color: transparent;
      }
      :after, :before {
        display: none;
      }
    }
  }
</style>
