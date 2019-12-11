<template>
  <q-page class="flex flex-center">
    <q-form
      @submit="send"
      autofocus
      class="q-gutter-lg">
      <q-input
        type="text"
        autofocus
        v-model="username"
        label="Username"
        hint="The username of forgotten password"
        @keyup.enter="send"
      />

      <q-btn
        label="Reset"
        type="submit"
        color="primary"
        :disabled="!ready"
        :loading="submit"/>
    </q-form>
  </q-page>
</template>

<script>
import axios from 'axios'
import { myMixin } from 'src/mixins'

import {
  QInput,
  // QField,
  QBtn
} from 'quasar'

export default {
  name: 'test',
  components: {
    QInput,
    // QField,
    QBtn
  },
  data () {
    return {
      username: '',
      submit: false
    }
  },
  computed: {
    ready () {
      return this.username !== ''
    }
  },
  mixins: [myMixin],
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
  }
}
</script>

<style lang="stylus">
</style>
