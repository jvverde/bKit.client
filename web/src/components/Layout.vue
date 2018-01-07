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
        <div slot="subtitle">Running on Quasar v{{$q.version}}</div>
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
      <div v-else>
        <span>{{user}}</span>
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
    </div>
    <router-view class="relative-position"></router-view>
  </q-layout>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  QLayout,
  QToolbar,
  QToolbarTitle,
  QBtn,
  QIcon,
  QList,
  QListHeader,
  QItem,
  QSideLink,
  QItemSide,
  QItemMain
} from 'quasar'

export default {
  name: 'layout',
  components: {
    QLayout,
    QToolbar,
    QToolbarTitle,
    QBtn,
    QIcon,
    QList,
    QListHeader,
    QItem,
    QItemSide,
    QSideLink,
    QItemMain
  },
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters('auth', [
      'token',
      'logged',
      'session',
      'user'
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
      logoff: 'logout'
    })
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
