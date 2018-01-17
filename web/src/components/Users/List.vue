<template>
  <q-list class="absolute-center full-width" dense no-border>
    <q-list-header class="text-center">Users</q-list-header>
    <q-item class="row"
      
      v-for="(user, index) in users"  
      :key="user.username"
    >
      <q-item-side class="hover flex justify-around no-wrap">
        <q-icon
          @click="remove(user)"
          name="delete forever"
          color="negative"
        />
        <q-icon
          @click="enable(user)"
          :name="user.state.enable ? 'lock open' : 'lock'"
          color="warning"
        />
        <q-icon
          @click="$router.push({ 
            name: 'userview',
            params: { name: user.username }
          })"
          name="person"
          color="secondary"
        />
      </q-item-side>

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
      return Object.keys(states || {})
        .filter(state => states[state])
        .join(' + ')
    },
    setusers (users) {
      this.users = (users || []).map(user => {
        user.access = user.access || {}
        user.state = user.state || {}
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
    enable (user) {
      let action = user.state.enable ? 'reset' : 'set'
      return axios.post(`/auth/user/${action}/enable`, [user.username])
        .then(response => {
          console.log(response.data)
          user.state.enable = !user.state.enable
        })
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

<style lang="scss">
  .hover {
    font-size: 150%;
    &> * {
      cursor: pointer;
    }
    &> :not(:first-child) {
      margin-left: 6px;
    }
  }
</style>
