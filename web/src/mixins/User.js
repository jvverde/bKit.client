import axios from 'axios'
import {myMixin} from 'src/mixins'
import { required, email } from 'vuelidate/lib/validators'

function getDate (v) {
  return v ? new Date(1000 * v) : null
}

export const User = {
  name: 'user.logic',
  data: function () {
    return {
      user: {a: 67}
    }
  },
  props: {
    name: {
      type: String,
      required: true
    }
  },
  mixins: [myMixin],
  computed: {
    access () {
      return this.user.access || {}
    },
    states () {
      return this.user.state || {}
    },
    lastTimeAccess () {
      return getDate(this.access.lastTime)
    },
    firstTimeAccess () {
      return getDate(this.access.firstTime)
    },
    activeStates () {
      return Object.keys(this.states).filter(s => this.states[s])
    },
    stateNames () {
      return this.activeStates.join(' ')
    },
    username () {
      return this.name
    },
    groups () {
      return this.user.groups
    },
    disabled () {
      return !this.states.enable
    },
    accessCnt () {
      return this.access.cnt
    },
    login () {
      return this.user.login || {}
    },
    loginCnt () {
      return this.login.cnt
    },
    lastTimeLogin () {
      return getDate(this.login.lastTime)
    },
    firstTimeLogin () {
      return getDate(this.login.firstTime)
    },
    logout () {
      return this.user.logout || {}
    },
    logoutCnt () {
      return this.logout.cnt
    },
    lastTimeLogout () {
      return getDate(this.logout.lastTime)
    },
    firstTimeLogout () {
      return getDate(this.logout.firstTime)
    }
  },
  mounted () {
    this.getUser()
  },
  methods: {
    getUser () {
      this.user = {}
      return axios.get(
        `/auth/user/${encodeURIComponent(this.name)}`
      ).then(response => {
        this.user = response.data
        console.log(this.user)
      }).catch(this.catch)
    },
    change_groups (user) {
      console.log(this.username, this.groups)
      axios.put(`auth/user/${encodeURIComponent(this.username)}/groups`,
        this.groups || []
      ).then(response => {
        if (response.data instanceof Array) {
          let groups = response.data
          this.groups.forEach(g => {
            if (groups.indexOf(g) === -1) {
              this.catch(new Error(`Group <b>${g}</b> doesn't exists`))
            }
          })
          this.user.groups = groups
        }
      }).catch(this.catch)
    },
    remove () {
      axios.delete(`/auth/user/${encodeURIComponent(this.username)}`)
        .then(response => this.$emit('deleted'))
        .catch(this.catch)
    },
    enable (user) {
      let action = this.states.enable ? 'reset' : 'set'
      return axios.post(`/auth/user/${action}/enable`, [this.username])
        .then(response => {
          this.user = response.data
        })
        .catch(this.catch)
    },
    reset_pass () {
      return axios.get(
        `/auth/user/reset_pass/${encodeURIComponent(this.username)}`
      ).then(this.done).catch(this.catch)
    },
    set_email () {
      return axios.post(
        '/auth/user/set_email', {
          email: this.user.email,
          username: this.username
        }
      ).then(response => {
        console.log(response.data)
      })
    },
    editUser (sel) {
      console.log(sel)
      sel.rows.forEach(r => {
        this.$router.push({
          name: 'userview',
          params: {username: r.data.username}
        })
      })
    }
  },
  validations: {
    user: {
      email: {
        required,
        email
      }
    }
  }
}
