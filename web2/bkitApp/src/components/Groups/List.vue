<template>
  <q-list class="absolute-top" dense no-border>
    <q-list-header class="text-center">Groups</q-list-header>
    <q-item
      link
      v-for="(group, index) in groups"
      :key="group.name"
    >
      <q-item-main :label="group.name">
        <q-chips-input
          style="padding-left:.5em"
          v-model="group.users"
          :placeholder="group.users.length ? '': 'Type a valid username'"
          color="blue-grey-5"
          @change="change(index)"
        />
      </q-item-main>
      <q-item-side
        right
        icon="delete forever"
        color="negative"
        @click="remove(index)"
      />
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
import {Dialog} from 'quasar'

export default {
  name: 'form',
  components: {
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
            handler: data => {
              axios.put(`/auth/group/${data.name}`, [])
                .then(response => {
                  if (response.data instanceof Array) {
                    this.groups.push({
                      name: data.name,
                      users: response.data
                    })
                  }
                }).catch(this.catch)
            }
          }
        ]
      })
    },
    remove (index) {
      let group = this.groups[ index ]
      axios.delete(`/auth/group/${group.name}`)
        .then(response => {
          if (response.data instanceof Array) {
            this.groups = response.data
          }
        }).catch(this.catch)
    },
    change (index) {
      let group = this.groups[ index ]
      axios.put(`/auth/group/${group.name}`, group.users)
        .then(response => {
          if (response.data instanceof Array) {
            group.users = response.data
          }
        }).catch(this.catch)
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
