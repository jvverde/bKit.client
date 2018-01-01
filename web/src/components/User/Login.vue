<template>
  <div class="column absolute-center"> 
    <q-input type="text" max-length="16" autofocus
      v-model="form.username"  float-label="Username"
      :error="$v.form.username.$error"
      @blur="$v.form.username.$touch"
      @keyup.enter="send"
    />  
    <q-input type="password" max-length="16" 
      v-model="form.password" float-label="Password"
      :error="$v.form.password.$error"
      @blur="$v.form.password.$touch"
      @keyup.enter="send"
    />
    <router-link to="/reset_pass" class="thin-paragraph text-right" style="margin:.5em 0">
      <small>Forgot Password?</small>
    </router-link>
    <q-btn v-model="submit" loader
      rounded color="secondary"
      :disabled="!ready" 
      @click="send"
    >
      Sign In
    </q-btn>
    <div class="text-center" style="margin:1em">Or</div>
    <q-btn rounded color="secondary"
      @click="$router.push('/sign_up')"
    >
      Sign up
    </q-btn>  
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
      form: {
        username: '',
        password: ''
      },
      submit: false
    }
  },
  validations: {
    form: {
      username: {
        required
      },
      password: {
        required
      }
    }
  },
  computed: {
    ready () {
      return !this.$v.form.$error && this.form.username && this.form.password
    }
  },
  methods: {
    send () {
      if (!this.ready) return
      this.submit = true
      axios.post('/auth/sign_in', this.form)
        .then(response => {
          this.submit = false
          console.log('done')
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
