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
        <div slot="subtitle">
          <u>Server</u> {{servername}}
          <q-popover v-model="showServers" 
            anchor="bottom left" 
            self="top left"
          >
            <q-list dense>
              <q-list-header>Servers</q-list-header>
              <q-item v-for="(server, index) in servers" :key="server">
                {{server}}
              </q-item>
              <q-item link @click="addServer">
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

import {
  Dialog,
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
      showServers: false
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
    addServer () {
      Dialog.create({
        title: 'New Server Address',
        form: {
          address: {
            type: 'text',
            label: 'Name/IP Address',
            model: ''
          },
          port: {
            type: 'text',
            label: 'Port Number',
            model: ''
          }
        },
        buttons: [
          'Cancel',
          {
            label: 'Apply',
            handler: data => {
              const server = `http://${data.address}:${data.port}`
              console.log(server)
              axios.get(`${server}/info`)
                .then(response => {
                  console.log(response.data)
                  this.server(server)
                }).catch(this.catch)
            }
          }
        ]
      })
    }
  },
  mounted () {
  },
  beforeDestroy () {
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
