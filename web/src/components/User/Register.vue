<template>
  <div class="column absolute-center">
    <q-input type="text" max-length="16" autofocus
      v-model="form.username"  float-label="Username"
      :error="$v.form.username.$error"
      @keyup.enter="send"
      @blur="$v.form.username.$touch"
    />  
    <q-input type="email" max-length="50"
      v-model="form.email"  float-label="Email"
      :error="$v.form.email.$error"
      @keyup.enter="send"
      @blur="$v.form.email.$touch"
    />  
    <q-input type="password" max-length="16" 
      v-model="form.password" float-label="Password"
      :error="$v.form.password.$error"
      @keyup.enter="send"
      @blur="$v.form.password.$touch"
    />
    <q-btn v-model="submit" loader
      rounded color="secondary"
      :disabled="!ready" 
      @click="send"
    >
      Sign up
    </q-btn>  
  </div>
</template>

<script>
import axios from 'axios'
import { required, minLength, email } from 'vuelidate/lib/validators'
import {
  QInput,
  QField,
  QBtn,
  Toast
} from 'quasar'

export default {
  name: 'register',
  components: {
    QInput,
    QField,
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
  validations: {
    form: {
      username: {
        required,
        minLength: minLength(4)
      },
      email: {
        required,
        email
      },
      password: {
        required,
        minLength: minLength(6)
      }
    }
  },
  computed: {
    ready () {
      return !this.$v.form.$error && this.form.username && this.form.email && this.form.password
    }
  },
  methods: {
    send () {
      if (!this.ready) return
      this.submit = true
      axios.post('/auth/sign_up', this.form)
        .then(res => {
          console.log((res.data))
          this.$router.push({path: '/show', query: {msg: res.data.msg}})
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
