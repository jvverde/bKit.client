<template>
  <ul class="breadcrumb">
    <li>
      <span>
       <router-link to="/" class="icon is-small"><i class="fa fa-home"></i></router-link>
      </span>
    </li>
    <li v-if="computerName">
      <span>
        <router-link to="/computers" class="icon is-small"><i class="fa fa-desktop"></i> {{computerName}}</router-link>
      </span>
    </li>
    <li v-if="computer && disk">
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
    <li v-if="snapDate">
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
      currentLocation () {
        return this.$store.getters.location || {}
      },
      computer () {
        return this.currentLocation.computer || ''
      },
      disk () {
        return this.currentLocation.disk || ''
      },
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
        const snap = this.currentLocation.snapshot || ''
        return moment.utc(snap.substring(5), 'YYYY.MM.DD-HH.mm.ss').local().format('DD-MM-YYYY HH:mm')
      },
      steps () {
        const path = this.currentLocation.path || ''
        const steps = path.split('/')
        steps.shift()
        let fullpath = '/'
        const obj = steps.map(e => {
          fullpath += e + '/'
          return {value: e, path: fullpath}
        })
        return obj
      }
    },
    props: [],
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
  @import "../../breadcrumb.scss";
</style>
