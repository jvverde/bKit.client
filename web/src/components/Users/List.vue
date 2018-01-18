<template>
  <q-list class="absolute-center full-width" dense no-border>
    <q-list-header class="text-center">Users</q-list-header>
    <user :name="user" v-for="user in users" :key="user"/>
<!--       <q-item-side class="hover flex justify-around no-wrap">
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
      </q-item-main> -->
  </q-list>

</template>

<script>
import axios from 'axios'
import {myMixin} from 'src/mixins'
import User from './User'

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
    User,
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
    getusers () {
      axios.get('/auth/users')
        .then(response => {
          this.users = response.data
        })
        .catch(this.catch)
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
