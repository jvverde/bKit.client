<template>
  <div class="q-pa-md q-gutter-sm">
    <q-dialog v-model="show" class="newserver">
      <q-layout view="hhh LpR fff" container class="bg-white">
        <q-page-container>
          <q-page padding>
            <q-form
              @submit="send"
              autofocus
              class="q-gutter-md">
              <q-input type="text" max-length="16"
                v-model="server.name"
                filled
                required
                label="Server Name"
                hint="Give a name to server"
                :rules="[ val => !!val || '* Required']"
                lazy-rules
                @keyup.enter="send"
              />
              <q-input type="text"
                max-length="16"
                autofocus
                required
                v-model="server.address"
                label="Server address"
                filled
                hint="Server name or IP Address"
                :rules="[ val => !!val || '* Required']"
                lazy-rules
                @keyup.enter="send"
              />
              <q-input type="number"
                max="65335"
                min="1024"
                v-model="server.port"
                label="Server Port"
                required
                filled
                hint="TCP Port Number where the server is listen"
                :rules="[
                  val => !!val || '* Required',
                  val => val < 65536 && val > 1024 || 'Please use valid port number',
                ]"
                lazy-rules
                @keyup.enter="send"
              />
              <div>
                <q-btn label="Apply" type="submit" color="primary" :loading="submitting"/>
                <q-btn v-if="!required" color="primary" @click="close" v-close-popup label="Cancel" flat class="q-ml-sm"/>
              </div>
            </q-form>
          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>
  </div>
</template>

<script>
import { mapActions } from 'vuex'
import { defaultName } from 'src/helpers/utils'
import { myMixin } from 'src/mixins'
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
  computed: {
    show: {
      get () {
        return this.open
      },
      set () {
      }
    }
  },
  props: ['open', 'required'],
  mixins: [myMixin],
  methods: {
    ...mapActions('auth', [
      'addServer'
    ]),
    send () {
      console.log('this.server=', this.server)
      this.submitting = true
      const url = `http://${this.server.address}:${this.server.port}`
      this.addServer({
        url: url,
        name: this.server.name
      }).then(() => this.$emit('close')).catch(this.catch).then(() => {
        this.submitting = false
      })
    },
    close () {
      this.$emit('close')
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
