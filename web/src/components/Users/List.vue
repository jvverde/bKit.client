<template>
  <q-list class="absolute-center full-width" dense no-border>
    <q-list-header class="text-center">Users</q-list-header>
    <q-item class="row"
      link
      v-for="(user, index) in users"  
      :key="user.username"
    >
      <q-item-side
        @click="remove(user)"
        icon="delete forever"
        color="negative"
      />
      <q-item-side class="col-1">
        {{user.username}}
      </q-item-side>
      <q-item-side  class="col-2">
        {{user.email}}
      </q-item-side>
      <q-item-side  class="col-1">
        {{getStates(user.state)}}
      </q-item-side>
      <q-item-side  class="col-1">
        {{user.access.cnt}}
      </q-item-side>
      <q-item-side  class="col-1">
        <span v-if="user.lastAccess !== null">
          {{user.lastAccess | moment("from")}}
        </span>
      </q-item-side>
      <q-item-main class="col">
        <q-chips-input 
          style="padding-left:.5em"
          v-model="user.groups"
          :placeholder="user.groups.length ? '': 'Type a valid group name'"
          color="blue-grey-5"
          @change="change_groups(user)"
        />
      </q-item-main>
    </q-item>
  </q-list>

</template>

<script>
import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  QChipsInput,
  QCard,
  QCardActions,
  QCardMain,
  QDataTable,
  QBtn,
  QIcon,
  QField,
  QInput,
  QList,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink
} from 'quasar'

export default {
  name: 'form',
  components: {
    QChipsInput,
    QCard,
    QCardActions,
    QCardMain,
    QDataTable,
    QBtn,
    QIcon,
    QField,
    QInput,
    QList,
    QListHeader,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide,
    QSideLink
  },
  data () {
    return {
      users: []
    }
  },
  mixins: [myMixin],
  methods: {
    getDate (value) {
      return value ? new Date(1000 * value) : null
    },
    getStates (states) {
      return Object.keys(states || {}).join(' + ')
    },
    setusers (users) {
      this.users = (users || []).map(user => {
        user.access = user.access || {}
        user.lastAccess = this.getDate(user.access.lastTime)
        user.groups = user.groups || []
        return user
      })
    },
    getusers () {
      axios.get('/auth/users')
        .then(response => this.setusers(response.data))
        .catch(this.catch)
    },
    change_groups (user) {
      console.log(user.username, user.groups)
      axios.put(`auth/user/${encodeURIComponent(user.username)}/groups`,
        user.groups || []
      ).then(response => {
        if (response.data instanceof Array) {
          let groups = response.data
          user.groups.forEach(g => {
            if (groups.indexOf(g) === -1) {
              this.catch(new Error(`Group <b>${g}</b> doesn't exists`))
            }
          })
          user.groups = groups
        }
      }).catch(this.catch)
    },
    remove (user) {
      axios.delete(`/auth/user/${encodeURIComponent(user.username)}`)
        .then(response => this.setusers(response.data))
        .catch(this.catch)
    },
    editUser (sel) {
      console.log(sel)
      sel.rows.forEach(r => {
        this.$router.push({
          name: 'userview',
          params: {username: r.data.username}
        })
      })
    }
  },
  mounted () {
    this.getusers()
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
