<template>
  <div class="flex column justify-center items-stretch users" dense no-border>
    <header class="text-center">Users</header>
    <user
      :name="user"
      @changed_email="changed_email"
      @deleted="removed"
      v-for="user in users"
      :key="user"
    />
  </div>
</template>

<script>
import axios from 'axios'
import { myMixin } from 'src/mixins'
import User from './User'

export default {
  name: 'users',
  components: {
    User
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
          console.log(this.users)
        })
        .catch(this.catch)
    },
    changed_email (msg) {
      this.show(msg)
    },
    removed (user) {
      console.log('removed: ', user)
      this.users = this.users.filter(u => u !== user)
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
  .users {
    height: 100%;
    overflow: auto;
  }
</style>
