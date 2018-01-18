<template>
  <q-item class="row">
    <q-item-side class="hover flex justify-around no-wrap">
      <q-icon
        @click="remove"
        name="delete forever"
        color="negative"
      />
      <q-icon
        @click="enable('set')"
        :name="disabled ? 'open' : 'lock open'"
        color="warning"
      />
      <q-icon
        @click="$router.push({ 
          name: 'userview',
          params: { name: username }
        })"
        name="person"
        color="secondary"
      />
    </q-item-side>

    <q-item-side class="col-1">
      {{username}}
    </q-item-side>
    <q-item-side  class="col-2">
      {{user.email}}
    </q-item-side>
    <q-item-side  class="col-1">
      {{getStates(user.state)}}
    </q-item-side>
    <q-item-side  class="col-1">
      {{accessCnt}}
    </q-item-side>
    <q-item-side  class="col-1">
      <span v-if="lastTimeAccess !== null">
        {{lastTimeAccess | moment("from")}}
      </span>
    </q-item-side>
    <q-item-main class="col">
      <q-chips-input 
        style="padding-left:.5em"
        v-model="groups"
        :placeholder="groups.length ? '': 'Type a valid group name'"
        color="blue-grey-5"
        @change="change_groups"
      />
    </q-item-main>
  </q-item>
</template>

<script>
import {
  QChipsInput,
  QIcon,
  QItem,
  QItemMain,
  QItemSide
} from 'quasar'
import {myMixin} from 'src/mixins'
import {User} from 'src/mixins/User'

export default {
  name: 'register',
  components: {
    QChipsInput,
    QIcon,
    QItem,
    QItemMain,
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
    getStates () {
      return Object.keys(this.states || {})
        .filter(state => this.states[state])
        .join(' + ')
    }
  },
  mounted () {
  }
}
</script>

<style lang="stylus">
</style>
