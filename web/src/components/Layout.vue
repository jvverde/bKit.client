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
                :key="server"
                link
                @click="changeServer(server)"
              >
                <q-item-main :label="server"/>
              </q-item>
              <q-item 
                link 
                @click="addServer" 
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
import addServer from 'src/helpers/addServer'

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
      ws: []
    }
  },
  computed: {
    wsURL () {
      return (this.servername || '').replace(/^http:/, 'ws:')
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
      server: 'server'
    }),
    changeServer (server) {
      axios.get(`${server}/info`)
        .then(response => {
          this.server(server)
        })
        .catch(this.catch)
    },
    addServer () {
      addServer()
    },
    websocket () {
      this.ws = new WebSocket('ws://localhost:3000/test')
      this.ws.onerror = (err) => console.log(err)
      this.ws.onopen = (msg) => console.log('WS Open:', msg)
      this.ws.onmessage = (msg) => {
        console.log('Msg: ', msg)
        this.messages.push(msg.data)
      }
      this.ws.onclose = (e) => console.log('WS Closed: ', e)
    }
  },
  mounted () {
    this.ws = []
    this.servers.forEach(servername => {
      const wsname = servername.replace(/^https?/, 'ws')
      const wsURL = `${wsname}/test`
      const ws = new WebSocket(wsURL)
      ws.onerror = (err) => console.log(`Error from ${wsURL}`, err)
      ws.onopen = (msg) => console.log(`WS Open to ${wsURL}`, msg)
      ws.onmessage = (msg) => {
        console.log(`Msg from ${wsURL}: `, msg)
      }
      ws.onclose = (e) => console.log(`WS to ${wsURL} Closed: `, e)
      this.ws.push(ws)
      console.log(wsURL)
    })
    if (!this.servername) {
      axios.get('/info')
        .then(response => {
          console.log(response)
          if (response.data) {
            this.server(response.data.baseUrl)
          }
          if (response.request && response.request.responseURL) {
            this.server(response.request.responseURL.replace(/\/info$/, ''))
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
