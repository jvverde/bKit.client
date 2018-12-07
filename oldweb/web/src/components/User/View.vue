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
            <q-input type="text" max-length="256"
              v-model="user.email"  float-label="Email"
              :error="$v.user.email.$error"
              @blur="$v.user.email.$touch"
              @keyup.enter="set_email"
            />
          </q-item-main>
        </q-item>
      </q-list>
    </q-card-main>
    <q-card-actions>
      <q-btn flat icon="autorenew" color="orange" @click="reset_pass">
        Reset Password
      </q-btn>
      <q-btn flat
        @click="remove" 
        icon="delete forever" 
        color="negative">
        Remove
      </q-btn>
      <q-btn flat icon="lock open" color="positive" 
        v-if="disabled"
        @click="enable('set')">
        Enable
      </q-btn>
      <q-btn flat icon="block" color="deep-orange" 
        v-else
        @click="enable('reset')">
        disable
      </q-btn>
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
import {User} from 'src/mixins/User'

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
  computed: {
  },
  mixins: [myMixin, User],
  methods: {
    replace_user (user) {
      this.getUser(user)
    },
    missing_group (g) {
      this.catch(new Error(`Group <b>${g}</b> doesn't exists`))
    },
    deleted (u) {
      this.show(`${u} deleted`)
    },
    changed_email (msg) {
      this.show(msg)
    }
  },
  mounted () {
  },
  beforeRouteUpdate (to, from, next) {
    this.replace_user(to.params.name)
    next()
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
