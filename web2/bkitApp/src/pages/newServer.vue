<template>
  <q-modal v-model="show" class="newserver">
    <form @submit.prevent>
      <q-input type="text" max-length="16"
        v-model="server.name"  float-label="Name"
        :error="$v.server.name.$error"
        @blur="$v.server.name.$touch"
        @keyup.enter="send"
      />
      <q-input type="text" max-length="16" autofocus
        v-model="server.address" float-label="Server address"
        :error="$v.server.address.$error"
        @blur="$v.server.address.$touch"
        @keyup.enter="send"
      />
      <q-input type="text" max-length="16"
        v-model="server.port" float-label="Server port"
        :error="$v.server.port.$error"
        @blur="$v.server.port.$touch"
        @keyup.enter="send"
      />
      <q-btn color="primary" @click="$emit('close')" label="Cancel" />
      <q-btn color="primary" @click="send" :loading="submitting" label="Apply" />
    </form>
  </q-modal>
</template>

<script>
import { required, numeric, between } from 'vuelidate/lib/validators'
import { mapActions } from 'vuex'
import { defaultName } from 'src/helpers/utils'
import {myMixin} from 'src/mixins'
export default {
  name: 'newServer',
  data () {
    return {
      submitting: false,
      server: {
        name: defaultName(),
        port: '',
        address: ''
      }
    }
  },
  validations: {
    server: {
      name: {
        required
      },
      address: {
        required
      },
      port: {
        required,
        numeric,
        between: between(1, 65535)
      }
    }
  },
  computed: {
    show: {
      get () {
        return this.open
      },
      set () {
      }
    },
    ready () {
      return !this.$v.server.$error
    }
  },
  props: ['open'],
  mixins: [myMixin],
  methods: {
    ...mapActions('auth', [
      'addServer'
    ]),
    send () {
      if (!this.ready) return
      this.submitting = true
      const url = `http://${this.server.address}:${this.server.port}`
      this.addServer({
        url: url,
        name: this.server.name
      }).then(() => this.$emit('close')).catch(this.catch).then(() => {
        this.submitting = false
      })
    }
  }
}
</script>
<style lang="scss">
  .newserver {
    * {
      border-radius: 5px;
    }
    form {
      margin: 1em;
      padding: 1em;
      border-radius: 50px;
    }
  }
</style>
