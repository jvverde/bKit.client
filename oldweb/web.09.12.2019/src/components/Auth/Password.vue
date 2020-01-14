<template>
  <div class="column absolute-center">
    <div class="layout-padding column">
      <big class="text-center">Choose a new password</big>
      <small class="text-center">User: {{username}}</small>
      <q-input type="password" max-length="16" v-model="pass" autofocus
        float-label="New Password"
        :error="$v.pass.$error"
        @blur="$v.pass.$touch"
      />
      <q-input type="password" max-length="16" v-model="confirm"
        float-label="Confirm"
        :error="$v.confirm.$error"
        @blur="$v.confirm.$touch"
        @keyup.enter="send"
      />
      <q-btn v-model="submit" loader
        rounded color="secondary"
        :disabled="!ready"
        @click="send"
      >
        Set New Pass
      </q-btn>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { required, sameAs, minLength } from 'vuelidate/lib/validators'
import { myMixin } from 'src/mixins'

export default {
  name: 'form',
  components: {
  },
  data () {
    return {
      pass: '',
      confirm: '',
      submit: false
    }
  },
  validations: {
    pass: {
      required,
      minLength: minLength(6)
    },
    confirm: {
      sameAsPassword: sameAs('pass')
    }
  },
  props: ['username'],
  computed: {
    ready () {
      return !this.$v.pass.$error && !this.$v.confirm.$error && this.pass
    }
  },
  mixins: [myMixin],
  methods: {
    send () {
      if (!this.ready) return
      this.submit = true
      axios.post('/auth/set_pass', {
        password: this.pass,
        confirm: this.confirm
      })
        .then(response => {
          this.submit = false
          console.log('done')
          this.$router.replace({
            path: '/show',
            query: { msg: response.data.msg }
          })
        })
        .catch(this.catch)
        .then(() => {
          this.submit = false
        })
    }
  },
  mounted () {
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
