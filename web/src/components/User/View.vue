<template>
  <div class="column absolute-center">
    <div class="layout-padding column">Username: {{username}}</div>
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
  props: ['username'],
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
      axios.post('/auth/signup', this.form)
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
