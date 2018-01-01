<template>
  <div class="layout-padding column fullscreen">
    <div class="layout-padding column">
      <q-input type="text" max-length="16" autofocus
        v-model="username"  float-label="Username"
        :error="$v.username.$error"
        @blur="$v.username.$touch"
        @keyup.enter="send"
      />  
      <q-btn v-model="submit" loader
        rounded color="secondary"
        :disabled="!ready" 
        @click="send"
      >
        Reset
      </q-btn>
    </div> 
  </div>
</template>

<script>
import axios from 'axios'
import { required } from 'vuelidate/lib/validators'

import {
  QInput,
  QField,
  QBtn,
  Toast
} from 'quasar'

export default {
  name: 'test',
  components: {
    QInput,
    QField,
    QBtn
  },
  data () {
    return {
      username: '',
      submit: false
    }
  },
  validations: {
    username: {
      required
    }
  },
  computed: {
    ready () {
      return !this.$v.$error && this.username
    }
  },
  methods: {
    send () {
      if (!this.ready) return
      this.submit = true
      axios.get(`/auth/reset_pass/${this.username}`)
        .then(response => {
          this.submit = false
          console.log('done', response.data)
          this.$router.replace({
            path: '/show',
            query: {msg: response.data.msg}
          })
        })
        .catch(e => {
          const msg = e.response.data.msg
          Toast.create.negative({
            html: msg,
            timeout: 10000
          })
        })
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
