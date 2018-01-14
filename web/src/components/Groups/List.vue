<template>
  <q-list class="absolute-center" dense no-border>
    <q-list-header class="text-center">Groups</q-list-header>
    <q-item 
      v-for="(group, index) in groups"  
      :key="group.name"
    >
      <q-item-main :label="group.name">
        <q-chips-input 
          v-model="group.users"
          :placeholder="group.users.length ? '': 'Type a valid username'"
          color="info"
          @change="change(index)"
        />
      </q-item-main>
    </q-item>
    <q-item-separator/>
    <q-item>
      <q-btn icon="add" color="primary" @click="add">Add</q-btn>
    </q-item>
  </q-list>
</template>

<script>
import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  Dialog,
  QToggle,
  QAutocomplete,
  QChipsInput,
  QCard,
  QCardActions,
  QCardMain,
  QDataTable,
  QItemSeparator,
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
    QToggle,
    QAutocomplete,
    QChipsInput,
    QCard,
    QCardActions,
    QCardMain,
    QDataTable,
    QItemSeparator,
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
      groups: []
    }
  },
  computed: {
  },
  mixins: [myMixin],
  methods: {
    getgroups () {
      axios.get('/auth/groups')
        .then(response => {
          this.groups = response.data
        })
        .catch(this.catch)
    },
    add () {
      Dialog.create({
        title: 'New group',
        form: {
          name: {
            type: 'text',
            label: 'Group Name',
            model: ''
          }
        },
        buttons: [
          'Cancel',
          {
            label: 'Ok',
            handler: data => this.groups.push({
              name: data.name,
              users: []
            })
          }
        ]
      })
    },
    search (value, done) {
      console.log('done:', value)
      done(['aqui', 'ali'])
    },
    change (index) {
      let group = this.groups[ index ]
      let username = group.users[ group.users.length - 1 ]
      console.log(group.name)
      axios.get(`/auth/check/${username}`)
        .then(response => {
          let user = response.data
          console.log(user)
          if (!user.exists) {
            group.users = group.users.filter(u => user.username !== u)
          } else {
            axios.put(`/auth/group/${group.name}`, group.users)
              .then(response => {
                if (response.data instanceof Array) {
                  group.users = response.data
                }
              }).catch(this.catch)
          }
        })
        .catch(this.catch)
    }
  },
  mounted () {
    this.getgroups()
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
