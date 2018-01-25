<template>
  <q-layout
    ref="layout"
    view="lHh Lpr fff"
    :left-class="{'bg-grey-2': true}"
  >
    <q-toolbar slot="header" class="glossy">
      <q-btn flat @click="$refs.layout.toggleLeft()">
        <q-icon name="menu" />
      </q-btn>

      <q-toolbar-title>
        bKit App
        <dd v-if="servername" slot="subtitle"> <!-- this is an workaround -->
          <u>Server</u>: {{servername}}
          <q-popover anchor="bottom left" self="top left"
            ref="popover" v-model="showServers">
            <q-list @click="$refs.popover.close()">
              <q-list-header>Servers</q-list-header>
              <q-item link v-for="(server, index) in orderedServers" 
                :key="server.name">
                <q-item-side icon="delete" color="warning"
                  @click="rmServer(server.name)"/>
                <q-item-main
                  @click="chgServer(server.name)"
                  :label="server.name"
                  :sublabel="server.url"
                />
              </q-item>
              <q-item link @click="newServer" dense>
                <q-item-side icon="add"/>
                <q-item-main label="Add a new server"/>
              </q-item>
            </q-list>
          </q-popover>
        </dd>
        <div v-else slot="subtitle" @click="newServer">
          <u>Add server</u>
        </div>      
      </q-toolbar-title>
      <div v-if="!logged">
        <q-btn
          flat
          @click="$router.replace({ name: 'login' })"
        >
          Sign In
        </q-btn>
        <span> | </span>
        <q-btn
          flat
          @click="$router.replace({ name: 'signup' })"
        >
          Sign Up
        </q-btn>
      </div>
      <div v-else class="flex column items-end">
        <div>{{user}}</div>
        <small><a href="#" @click="signout">Logout</a></small>
      </div>
      <div v-show="alerts">
        <q-btn flat round small icon="notifications"
          @click="$router.push({ name: 'alerts' })">
        </q-btn>
      </div>
    </q-toolbar>

    <div slot="left">
      <q-side-link item to="/test" exact>
        <q-item-main label="About" />
      </q-side-link>
      <q-side-link item to="/users">
        <q-item-main label="Users" />
      </q-side-link>
      <q-side-link item to="/groups">
        <q-item-main label="Groups" />
      </q-side-link>
    </div>
    <router-view class="relative-position"></router-view>
  </q-layout>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import axios from 'axios'
import {myMixin} from 'src/mixins'
import newServer from 'src/helpers/newServer'
import * as websocks from 'src/helpers/websocks'

import {
  QLayout,
  QToolbar,
  QToolbarTitle,
  QPopover,
  QBtn,
  QIcon,
  QList,
  QListHeader,
  QItem,
  QSideLink,
  QItemSide,
  QItemTile,
  QItemMain
} from 'quasar'

export default {
  name: 'layout',
  components: {
    QLayout,
    QToolbar,
    QToolbarTitle,
    QPopover,
    QBtn,
    QIcon,
    QList,
    QListHeader,
    QItem,
    QItemSide,
    QItemTile,
    QSideLink,
    QItemMain
  },
  data () {
    return {
      showServers: false,
      alerts: false,
      ws: []
    }
  },
  computed: {
    ...mapGetters('auth', [
      'token',
      'logged',
      'session',
      'user',
      'servername',
      'servers'
    ]),
    orderedServers () {
      return this.servers.slice().sort(
        (a, b) => (a.name || '').localeCompare(b.name || '')
      )
    }
  },
  mixins: [myMixin],
  methods: {
    signout () {
      axios.get('/auth/logout')
        .then(response => {
          this.logout()
          this.$router.replace({
            path: '/show',
            query: {msg: response.data.msg}
          })
        })
        .catch(this.catch)
    },
    ...mapActions('auth', [
      'logout',
      'chgServer',
      'rmServer',
      'addServer'
    ]),
    ...mapMutations('alerts', [
      'push'
    ]),
    newServer () {
      newServer()
    },
    websocket (server, delay = 1) {
      const wsname = server.url.replace(/^https?/, 'ws')
      const wsURL = `${wsname}/ws/tail`
      const ws = websocks.create(wsURL)
      ws.onerror = (err) => console.log(`Error from ${wsURL}`, err)
      ws.onopen = (msg) => console.log(`WS Open to ${wsURL}`, msg)
      ws.onmessage = (msg) => {
        let data = typeof msg.data === 'string'
          ? JSON.parse(msg.data)
          : msg.data
        console.log(data)
        this.push({
          name: server.name,
          data: data,
          from: (msg.target || {}).url,
          url: wsURL,
          date: new Date()
        })
        this.alerts = true
      }
      ws.onclose = (e) => {
        console.log(`WS to ${wsURL} closed: `, e)
        console.log('delay=', delay)
        if (delay < 65536) {
          setTimeout(
            () => this.websocket(server, delay * 2),
            1000 * delay
          )
        }
        websocks.remove(wsURL)
      }
      this.ws.push(ws)
    }
  },
  mounted () {
    this.ws = []
    this.servers.forEach(server => this.websocket(server))
    if (!this.servername) {
      axios.get('/info')
        .then(response => {
          let url0 = (response.data || {}).baseUrl
          if (url0) {
            this.addServer({
              url: url0,
              name: 'Local Server 0'
            })
          }
          let url1 = ((response.request || {}).responseURL || '')
            .replace(/\/info$/, '')
          if (url1 && url1 !== url0) {
            this.addServer({
              url: url1,
              name: 'Local Server 1'
            })
          }
        })
        .catch(this.catch)
    }
  },
  beforeDestroy () {
    this.ws.forEach(ws => ws.close())
  }
}
</script>

<style lang="stylus">
.logo-container
  width 255px
  height 242px
  perspective 800px
  position absolute
  top 50%
  left 50%
  transform translateX(-50%) translateY(-50%)
.logo
  position absolute
  transform-style preserve-3d
</style>
