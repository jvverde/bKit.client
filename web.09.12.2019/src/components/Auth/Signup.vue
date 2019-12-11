<template>
  <q-page class="flex flex-center">
    <q-form
      ref="signupForm"
      @submit="send"
      autofocus
      class="q-gutter-lg">
      <q-input
        type="text"
        max-length="16"
        autofocus
        v-model="form.username"
        label="Username"
        @keyup.enter="send"
      />
      <q-input
        type="email"
        max-length="50"
        v-model="form.email"
        label="Email"
        @keyup.enter="send"
      />
      <q-input
        type="password"
        max-length="16"
        v-model="form.password"
        label="Password"
        @keyup.enter="send"
      />
      <q-btn v-model="submit"
        :loading="submit"
        rounded
        color="primary"
        @click="send"
      >
        Sign up
      </q-btn>
    </q-form>
  </q-page>
</template>

<script>
import axios from 'axios'
import {
  QInput,
  // QField,
  QBtn
} from 'quasar'
import { myMixin } from 'src/mixins'

export default {
  name: 'register',
  components: {
    QInput,
    // QField,
    QBtn
  },
  data () {
    return {
      form: {
        username: '',
        password: '',
        email: ''
      },
      submit: false
    }
  },
  computed: {
  },
  mixins: [myMixin],
  methods: {
    send () {
      this.$refs.signupForm.validate()
        .then(success => {
          this.submit = true
          console.log('success => ', success)
          axios.post('/auth/signup', this.form)
            .then(res => {
              console.log((res.data))
              this.$router.push({ path: '/show', query: { msg: res.data.msg } })
            })
            .catch(this.catch)
            .then(() => {
              this.submit = false
            })
        })
        .catch(this.catch)
        .then(() => {
          this.submit = false  
        })
    }
  },
  mounted () {
  }
}
</script>

<style lang="stylus">
</style>
