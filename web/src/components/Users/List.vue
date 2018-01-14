<template>
  <q-list class="absolute-center full-width" dense no-border>
    <q-list-header class="text-center">Users</q-list-header>
    <q-item class="row"
      link
      v-for="(user, index) in users"  
      :key="user.username"
    >
      <q-item-side
        @click="remove(index)"
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
          @change="change(index)"
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
  Toast,
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
    getusers () {
      axios.get('/auth/users')
        .then(response => {
          this.users = (response.data || []).map(user => {
            user.access = user.access || {}
            user.lastAccess = this.getDate(user.access.lastTime)
            user.groups = user.groups || []
            return user
          })
          console.log(this.users)
        })
        .catch(this.catch)
    },
    refresh (done) {
      this.getusers()
      done()
    },
    deleteUsers (sel) {
      let remove = {}
      sel.rows.forEach(r => {
        remove[r.data.username] = r
        //  this.table.splice(row.index, 1)
        axios.delete(`/auth/user/${encodeURIComponent(r.data.username)}`)
          .then(response => {
            this.$set(
              this.users[remove[response.data.user].index], 'removed', true
            )
          })
          .catch(e => {
            let msg = e.toString()
            if (e.response instanceof Object &&
              e.response.data instanceof Object) {
              msg = `<small>${msg}</small><br/><i>${e.response.data.msg}</i>`
            }
            Toast.create.negative({
              html: msg,
              timeout: 10000
            })
          })
      })
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
