<template>
  <q-layout view="hHh LpR fFf">
    <q-header>
      <q-toolbar color="primary" glossy>
        <q-btn flat dense round @click="leftDrawerOpen = !leftDrawerOpen">
          <q-icon name="menu" />
        </q-btn>
        <q-toolbar-title>
          bKit App
          <dd v-if="servername" slot="subtitle"> <!-- this is an workaround -->
            <u>Server</u>: {{servername}}
            <q-popover anchor="bottom left" self="top left"
              ref="mypopover" v-model="showServers">
              <q-list @click.native="$refs.mypopover.hide()"
                link separator class="scroll" style="min-width: 100px">
                <q-item>Servers</q-item>
                <q-item link v-for="server in orderedServers"
                  :key="server.name">
                  <q-item-section>
                    <q-icon="delete" color="warning"
                      @click.native="rmServer(server.name)"/>
                    <q-item-label
                      @click.native="chgServer(server.name)"
                    >
                    {{server.name}}
                    </q-item-label>
                  </q-item-section>
                </q-item>
                <q-item link @click.native="askServer = true" dense>
                  <q-item-section>
                    <q-icon="add"/>
                    <q-item-label>Add a new server</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-popover>
          </dd>
          <div v-else slot="subtitle" @click="askServer = true">
            <u style="cursor:pointer">Add server</u>
          </div>
        </q-toolbar-title>
        <div v-if="!logged">
          <q-btn
            flat
            @click="$router.replace({ name: 'signin' })"
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
    </q-header>
    <q-drawer v-model="leftDrawerOpen" content-class="bg-grey-2">
      <q-list no-border link inset-delimiter>
        <q-item>
          <bkitlogo class="logo"></bkitlogo>
        </q-item>
        <q-item @click.native="$router.replace({ name: 'remote-computers' })">
          <q-icon name="settings backup restore"/>
          <q-item-label>Backups</q-item-label>
        </q-item>
        <q-item @click.native="$router.replace({ name: 'groups' })">
          <q-icon name="fa fa-users"/>
          <q-item-label>Groups</q-item-label>
        </q-item>
        <q-item @click.native="$router.replace({ name: 'users' })">
          <q-icon name="fa fa-user"/>
          <q-item-label>Users</q-item-label>
        </q-item>
        <q-item @click.native="$router.replace({ name: 'alerts' })">
          <q-icon name="fa fa-envelope" />
          <q-item-label>Alerts</q-item-label>
        </q-item>
      </q-list>
<!--       <q-side-link item to="/test" exact>
        <q-item-main label="About" />
      </q-side-link>
-->

    </q-drawer>
    <new-server :open="askServer" @close="askServer = false"/>
    <q-page-container style="height:100vh">
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { openURL } from 'quasar'
import { mapGetters, mapActions, mapMutations } from 'vuex'
import axios from 'axios'
import { myMixin } from 'src/mixins'
import * as websocks from 'src/helpers/websocks'
import newServer from 'src/pages/newServer'

export default {
  name: 'LayoutDefault',
  data () {
    return {
      leftDrawerOpen: false,
      showServers: false,
      alerts: false,
      ws: [],
      ask_server: false
    }
  },
  components: {
    newServer
  },
  computed: {
    askServer: {
      get: function () {
        return (this.ask_server || !this.baseURL)
      },
      set: function (v) {
        this.ask_server = v
      }
    },
    ...mapGetters('auth', [
      'token',
      'logged',
      'session',
      'user',
      'servername',
      'servers',
      'baseURL'
    ]),
    orderedServers () {
      return this.servers.slice().sort(
        (a, b) => (a.name || '').localeCompare(b.name || '')
      )
    }
  },
  mixins: [myMixin],
  methods: {
    openURL,
    signout () {
      axios.get('/auth/logout')
        .then(response => {
          this.logout()
          this.$router.replace({
            path: '/show',
            query: { msg: response.data.msg }
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
    websocket (server, delay = 1) {
      const wsname = server.url.replace(/^https?/, 'ws')
      const wsURL = `${wsname}/ws/alerts`
      const ws = websocks.create(wsURL)
      ws.onerror = (err) => console.log(`Error from ${wsURL}`, err)
      ws.onopen = (msg) => {
        delay = 1
        console.log(`WS Open to ${wsURL}`, msg)
      }
      const ask = {}
      const replay = (id) => {
        ws.send(JSON.stringify({
          id: id,
          answer: ask[id]
        }))
        setTimeout(() => delete ask[id], 120000)
      }
      ws.onmessage = (msg) => {
        console.log(msg)
        let data = typeof msg.data === 'string'
          ? JSON.parse(msg.data)
          : msg.data
        if (data.type === 'udp') {
          let [code, question, cnt, drive, volume, id] = data.msg.split('|')
          console.log(id, cnt, code, question, drive, volume)
          if (ask.hasOwnProperty(id)) {
            if (ask[id] !== null) replay(id)
          } else {
            ask[id] = null
            this.$q.dialog({
              title: `Server: ${wsname}`,
              message: question,
              noBackdropDismiss: true,
              noEscDismiss: true,
              ok: 'Yes',
              cancel: 'No'
            }).then(() => {
              ask[id] = 'YES'
            }).catch(() => {
              ask[id] = 'NO'
            }).then(() => replay(id))
          }
        } else if (data.type === 'reset') {
          // remove ask[i] and Dialog
        }
      }
      ws.onclose = (e) => {
        console.log(`WS to ${wsURL} closed: `, e)
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
              name: 'Local Server (0)'
            })
          }
          let url1 = ((response.request || {}).responseURL || '')
            .replace(/\/info$/, '')
          if (url1 && url1 !== url0) {
            this.addServer({
              url: url1,
              name: 'Local Server (1)'
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

<style>
</style>
