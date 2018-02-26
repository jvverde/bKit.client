<template>
  <q-modal v-model="show" class="newserver">
    <form @submit.prevent>
      <q-input type="text" max-length="16"
        v-model="form.serverName"  float-label="Name"
        :error="$v.form.serverName.$error"
        @blur="$v.form.serverName.$touch"
        @keyup.enter="send"
      />
      <q-input type="text" max-length="16" autofocus
        v-model="form.address" float-label="Server address"
        :error="$v.form.address.$error"
        @blur="$v.form.address.$touch"
        @keyup.enter="send"
      />
      <q-input type="text" max-length="16"
        v-model="form.port" float-label="Server port"
        :error="$v.form.port.$error"
        @blur="$v.form.port.$touch"
        @keyup.enter="send"
      />
      <q-btn color="primary" @click.native="$emit('close')" label="Cancel" />
      <q-btn color="primary" @click.native="send" label="Apply" />
    </form>
  </q-modal>
</template>

<script>
import { required } from 'vuelidate/lib/validators'
import { mapActions } from 'vuex'
import { defaultName, notify } from 'src/helpers/utils'
export default {
  name: 'newServer',
  data () {
    return {
      form: {
        serverName: defaultName(),
        port: '',
        address: ''
      }
    }
  },
  validations: {
    form: {
      serverName: {
        required
      },
      address: {
        required
      },
      port: {
        required
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
      return !this.$v.form.$error
    }
  },
  props: ['open'],
  methods: {
    ...mapActions('auth', [
      'addServer'
    ]),
    send () {
      if (!this.ready) return
      this.submit = true
      const url = `http://${this.form.address}:${this.form.port}`
      this.addServer({
        url: url,
        name: this.form.name
      }).then(() => this.$emit('close')).catch(notify)
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
