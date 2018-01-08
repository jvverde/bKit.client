<template>
  <q-card>
    <q-card-title>
      {{username}}
      <q-icon slot="right" name="account box" size="48px" color="info">
      </q-icon>    
    </q-card-title>
    <q-card-separator />
    <q-card-main>
      <q-list>
        <q-item>
          <q-item-side>
            <q-item-tile color="info" icon="mail outline"/>
          </q-item-side>
          <q-item-main>
            <q-input type="text" max-length="16"
              v-model="user.email"  float-label="Email"
              :error="$v.user.email.$error"
              @blur="$v.user.email.$touch"
              @keyup.enter="send"
            />
          </q-item-main>
        </q-item>
      </q-list>
    </q-card-main>
    <q-card-actions>
      <q-btn flat icon="autorenew" color="orange">Reset Password</q-btn>
      <q-btn flat icon="delete forever" color="red">Remove</q-btn>
    </q-card-actions>
    <q-card-main>
      <table class="q-table" responsive>
        <thead>
          <tr>
            <th class="text-center">Operation</th>
            <th class="text-center">Count</th>
            <th class="text-center">First</th>
            <th class="text-center">Last</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="access">
            <td class="text-right" data-th="Operation">Access</td>
            <td class="text-center" data-th="Count">{{accessCnt}}</td>
            <td class="text-center" data-th="First">
              <span v-if="firstTimeAccess">
                {{firstTimeAccess| moment("ddd DD-MM-Y, HH:mm:ss")}}
              </span>
            </td>
            <td class="text-center" data-th="Last">
              <span v-if="lastTimeAccess">
                {{lastTimeAccess | moment('from')}}
              </span>
            </td>
          </tr>
          <tr v-if="login">
            <td class="text-right" data-th="Operation">Login</td>
            <td class="text-center" data-th="Count">{{loginCnt}}</td>
            <td class="text-center" data-th="First">
              <span v-if="firstTimeLogin">
                {{firstTimeLogin| moment("ddd DD-MM-Y, HH:mm:ss")}}
              </span>
            </td>
            <td class="text-center" data-th="Last">
              <span v-if="lastTimeLogin">
                {{lastTimeLogin | moment('from')}}
              </span>
            </td>
          </tr>
          <tr v-if="logout">
            <td class="text-right" data-th="Operation">Logout</td>
            <td class="text-center" data-th="Count">{{logoutCnt}}</td>
            <td class="text-center" data-th="First">
              <span v-if="firstTimeLogout">
                {{firstTimeLogout | moment("ddd DD-MM-Y, HH:mm:ss")}}
              </span>
            </td>
            <td class="text-center" data-th="Last">
              <span v-if="lastTimeLogout">
                {{lastTimeLogout | moment('from')}}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </q-card-main>
  </q-card>
</template>

<script>
import axios from 'axios'
import { required, email } from 'vuelidate/lib/validators'
import {
  QInput,
  QBtn,
  QCardActions,
  QIcon,
  QCard,
  QCardTitle,
  QCardMain,
  QCardSeparator,
  QList,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide
} from 'quasar'
import {myMixin} from 'src/mixins'

export default {
  name: 'register',
  components: {
    QInput,
    QCardActions,
    QBtn,
    QIcon,
    QCard,
    QCardTitle,
    QCardMain,
    QCardSeparator,
    QList,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide
  },
  props: ['username'],
  data () {
    return {
      user: {}
    }
  },
  validations: {
    user: {
      email: {
        required,
        email
      }
    }
  },
  computed: {
    ready () {
      return !this.$v.form.$error && this.form.username && this.form.email && this.form.password
    },
    access () {
      return (this.user || {}).access || {}
    },
    accessCnt () {
      return this.access.cnt
    },
    lastTimeAccess () {
      if (this.access.lastTime) {
        return new Date(1000 * this.access.lastTime)
      } else return null
    },
    firstTimeAccess () {
      if (this.access.firstTime) {
        return new Date(1000 * this.access.firstTime)
      } else return null
    },
    login () {
      return (this.user || {}).login || {}
    },
    loginCnt () {
      return this.login.cnt
    },
    lastTimeLogin () {
      if (this.login.lastTime) {
        return new Date(1000 * this.login.lastTime)
      } else return null
    },
    firstTimeLogin () {
      if (this.login.firstTime) {
        return new Date(1000 * this.login.firstTime)
      } else return null
    },
    logout () {
      return (this.user || {}).logout || {}
    },
    logoutCnt () {
      return this.logout.cnt
    },
    lastTimeLogout () {
      if (this.logout.lastTime) {
        return new Date(1000 * this.logout.lastTime)
      } else return null
    },
    firstTimeLogout () {
      if (this.logout.firstTime) {
        return new Date(1000 * this.logout.firstTime)
      } else return null
    }
  },
  mixins: [myMixin],
  methods: {
    getUser (user) {
      return axios.get(
        `/auth/user/${encodeURIComponent(user || this.username)}`
      ).then(response => {
        this.user = response.data.info
        console.log(this.user)
      }).catch((e) => {
        this.catch(e)
        this.user = {}
      })
    },
    email (evt) {
      console.log(evt)
    }
  },
  mounted () {
    this.getUser()
  },
  beforeRouteUpdate (to, from, next) {
    this.getUser(to.params.username)
    next()
  },
  beforeDestroy () {
    console.log('View destroyed')
  }
}
</script>

<style lang="stylus">
</style>
