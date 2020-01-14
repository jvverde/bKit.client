<template>
  <q-list class="flex column justify-center items-stretch" dense no-border>
    <q-list-header class="text-center">Groups</q-list-header>
    <q-item v-for="(group, index) in groups" :key="group.name">
      <q-item-side color="negative">
        <q-btn flat round icon="delete forever" @click="remove(index)"/>
      </q-item-side>
      <q-item-main :label="group.name">
        <q-chips-input
          style="padding-left:.5em"
          v-model="group.users"
          :placeholder="group.users.length ? '': 'Type a valid username'"
          color="blue-grey-5"
          @input="change(index)"
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
import { myMixin } from 'src/mixins'

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
    log (msg) {
      console.log(msg)
    },
    getgroups () {
      axios.get('/auth/groups')
        .then(response => {
          this.groups = response.data
        })
        .catch(this.catch)
    },
    add () {
      this.$q.dialog({
        title: 'New group',
        message: 'Enter new group name',
        prompt: {
          type: 'text',
          model: ''
        },
        cancel: true,
        color: 'secondary'
      }).then(data => {
        axios.put(`/auth/group/${data}`, [])
          .then(response => {
            if (response.data instanceof Array) {
              this.groups.push({
                name: data,
                users: response.data
              })
            }
          }).catch(this.catch)
      }).catch()
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
