<template>
  <section class="row line items-start">
    <div class="icons hover flex justify-around no-wrap col-auto" title="Action">
      <q-icon
        @click="remove"
        name="delete forever"
        color="negative"
      />
      <q-icon
        @click="enable"
        :name="disabled ? 'lock' : 'lock open'"
        :color="disabled ? 'warning' : 'positive'"
      />
      <q-icon
        @click="$router.push({
          name: 'userview',
          params: { name: username }
        })"
        name="person"
        color="tertiary"
      />
    </div>

    <div class="col-1" title="User">
      {{username}}
    </div>
    <div class="col-2" title="Email">
      {{user.email}}
    </div>
    <div class="col-1" title="State">
      {{getStates(user.state)}}
    </div>
    <div class="col-1" title="Access Cnt">
      {{accessCnt}}
    </div>
    <div class="col-1" title="Last Access">
      <span v-if="lastTimeAccess !== null">
        {{fromNow}}
      </span>
    </div>
    <div class="col" title="Groups">
      <q-chips-input
        style="padding-left:.5em"
        v-model="groups"
        :placeholder="groups.length ? '': 'Type a valid group name'"
        color="blue-grey-5"
        @change="change_groups"
      />
    </div>
  </section>
</template>

<script>
import {myMixin} from 'src/mixins'
import {User} from 'src/mixins/User'
import moment from 'moment'
moment.locale('en')

export default {
  name: 'register',
  components: {
  },
  computed: {
    fromNow () {
      return moment.utc(this.lastTimeAccess, 'YYYY.MM.DD-HH.mm.ss').local().fromNow(true)
    }
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
      this.$emit('deleted', u)
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

<style lang="scss" scoped>
  .icons {
    margin-right: 6px;
  }
  .hover {
    &> * {
      font-size: 150%;
      cursor: pointer;
    }
    &> :not(:first-child) {
      margin-left: 6px;
    }
  }
  section[class~="line"]:first-of-type {
    margin-top: 3em;
    [title] {
      position: relative;
      &::before {
        position: absolute;
        bottom: 100%;
        margin-bottom: 1em;
        content: attr(title);
        font-weight: bold;
      }
    }
  }
</style>
