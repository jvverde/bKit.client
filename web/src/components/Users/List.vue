<template>
  <div class="absolute-top full-width" dense no-border>
    <header class="text-center">Users</header>
    <user 
      :name="user"
      @changed_email="changed_email" 
      v-for="user in users" 
      :key="user"
    />
  </div>
</template>

<script>
import axios from 'axios'
import {myMixin} from 'src/mixins'
import User from './User'

import {
  QList
} from 'quasar'

export default {
  name: 'form',
  components: {
    User,
    QList
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
    },
    changed_email (msg) {
      this.show(msg)
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
</style>
