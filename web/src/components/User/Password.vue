<template>
  <div class="column absolute-center">
    <div class="layout-padding column">
      <h5>Choose a new password</h5>
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
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { required, sameAs, minLength } from 'vuelidate/lib/validators'
import {
  QField,
  QInput,
  QList,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink,
  Toast
} from 'quasar'

export default {
  name: 'form',
  components: {
    QField,
    QInput,
    QList,
    QListHeader,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide,
    QSideLink,
    Toast
  },
  data () {
    return {
      pass: '',
      confirm: ''
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
  computed: {
    ready () {
      return !this.$v.pass.$error && !this.$v.confirm.$error && this.pass
    }
  },
  methods: {
    send () {
      if (!this.ready) return
      this.submit = true
      axios.post('/auth/xxxx', {newpass: this.pass})
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
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
