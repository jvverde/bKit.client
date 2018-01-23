<template>
  <q-layout
    ref="layout"
    view="lHh Lpr fff"
    :left-class="{'bg-grey-2': true}"
  >
    <q-toolbar slot="header" class="glossy">
      <q-btn
        flat
        @click="$refs.layout.toggleLeft()"
      >
        <q-icon name="menu" />
      </q-btn>

      <q-toolbar-title>
        bKit App
        <div slot="subtitle" v-if="servername">
          <u>Server</u> {{servername}} // {{wsURL}}
          <q-popover 
            ref="popover"
            v-model="showServers" 
            anchor="bottom left" 
            self="top left"
          >
          <q-list
              @click="$refs.popover.close()"
            >
              <q-list-header>Servers</q-list-header>
              <q-item 
                v-for="(server, index) in servers" 
                :key="server.name"
                link
              >
                <q-item-side icon="delete" color="warning" 
                  @click="rmServer(server.name)"
                />
                <q-item-main 
                  @click="changeServer(server.name)"
                  :label="server.name"
                  :sublabel="server.url"
                />
              </q-item>
              <q-item 
                link 
                @click="newServer" 
                dense
              >
                <q-item-side icon="add"/>
                <q-item-main label="Add a new server"/>
              </q-item>
            </q-list>
          </q-popover>
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
        <small><a href="#" @click="logout">Logout</a></small>
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
import { mapGetters, mapActions } from 'vuex'
import axios from 'axios'
import {myMixin} from 'src/mixins'
import newServer from 'src/helpers/newServer'
// import * as websocks from 'src/helpers/websocks'

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
      ws: [],
      messages: []
    }
  },
  computed: {
    wsURL () {
      return (this.servername || '').replace(/^http:/, 'ws:')
    },
    servernames () {
      return this.servers.map(s => s.name)
    },
    ...mapGetters('auth', [
      'token',
      'logged',
      'session',
      'user',
      'servername',
      'servers'
    ])
  },
  mixins: [myMixin],
  methods: {
    logout () {
      axios.get('/auth/logout')
        .then(response => {
          this.logoff()
          this.$router.replace({
            path: '/show',
            query: {msg: response.data.msg}
          })
        })
        .catch(this.catch)
    },
    ...mapActions('auth', {
      logoff: 'logout',
      server: 'server',
      rmServer: 'rmServer',
      'addServer': 'addServer',
      'reset': 'reset'
    }),
    changeServer (server) {
      axios.get(`${server}/info`)
        .then(response => {
          this.server(server)
        })
        .catch(this.catch)
    },
    newServer () {
      newServer()
    }
  },
  mounted () {
    this.ws = []
    /*    this.servers.forEach(server => {
      console.log('server:', server)
      const wsname = server.url.replace(/^https?/, 'ws')
      const wsURL = `${wsname}/ws/events`
      const ws = websocks.create(wsURL)
      ws.onerror = (err) => console.log(`Error from ${wsURL}`, err)
      ws.onopen = (msg) => console.log(`WS Open to ${wsURL}`, msg)
      ws.onmessage = (msg) => {
        console.log(`Msg from ${wsURL}: `, msg)
        this.messages.push({
          name: server.name,
          msg: msg
        })
      }
      ws.onclose = (e) => {
        console.log(`WS to ${wsURL} closed: `, e)
        websocks.remove()
      }
      this.ws.push(ws)
    })
    */
    this.reset()
    if (!this.servername) {
      console.log('getinfo')
      axios.get('/info')
        .then(response => {
          console.log('res:', response)
          if (response.data) {
            console.log('Add local server')
            this.addServer({
              url: response.data.baseUrl,
              name: 'Local Server 0'
            })
          }
          if (response.request && response.request.responseURL) {
            this.addServer({
              url: response.request.responseURL.replace(/\/info$/, ''),
              name: 'Local Server 1'
            })
          }
        })
        .catch(e => e)
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
