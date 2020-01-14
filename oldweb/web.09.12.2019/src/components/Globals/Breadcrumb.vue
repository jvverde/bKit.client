<template>
  <ul class="breadcrumb_bkit">
    <li>
      <span>
        <router-link :to="{
          name:'remote-computers'
        }" class="icon is-small">
          <i class="fas fa-server"></i>
        </router-link>
      </span>
    </li>
    <li v-if="computerName">
      <span>
        <router-link :to="{
          name:'remote-computers',
          params: {
            selected: computer
          }
        }" class="icon is-small">
          <i class="fas fa-desktop"></i>
          {{computerName}}
        </router-link>
      </span>
    </li>
    <li v-if="computer && disk">
      <span>
        <router-link :to="{
          name: 'remote-disk',
          params: {
            computer: computer,
            disk:disk
          }
        }" class="icon is-small">
          <i class="fa fa-hdd"></i>
          {{diskName}}
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
    <li v-for="(step, ind) in steps" :key="ind">
      <span>
        <a @click.stop="selectPath(step.path)">
          <i class="fa fa-folder-open"></i> {{step.value}}
        </a>
      </span>
    </li>
  </ul>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
let moment = require('moment')
moment.locale('en')

export default {
  name: 'breadcrumb',
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters('location', ['getLocation']),
    currentLocation () {
      return this.getLocation
    },
    computer () {
      return this.currentLocation.computer || ''
    },
    disk () {
      return this.currentLocation.disk || ''
    },
    computerName () {
      return this.computer.split('/')[1]
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
        return { value: decodeURIComponent(e), path: fullpath }
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
    ...mapMutations('location', ['setLocation']),
    selectPath (path) {
      const newLoc = Object.assign({}, this.currentLocation, { path: path })
      this.setLocation(newLoc)
    }
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/breadcrumb.scss";
</style>
