import axios from 'axios'
import {myMixin} from 'src/mixins'
import { required, email } from 'vuelidate/lib/validators'

function getDate (v) {
  return v ? new Date(1000 * v) : null
}

export const User = {
  name: 'user.logic',
  data () {
    return {
      user: {}
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
    access: () => this.user.access,
    states: () => this.user.state,
    lastTimeAccess: () => getDate(this.access.lastTime),
    firstTimeAccess: () => getDate(this.access.firstTime),
    activeStates: () => Object.keys(this.states).filter(s => this.states[s]),
    stateNames: () => this.activeStates.join(' '),
    username: () => this.name,
    groups: () => this.user.groups,
    disabled: () => !this.user.state.enable,
    accessCnt: () => this.access.cnt
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
        let user = Object.assign({
          access: {},
          state: {},
          groups: []
        }, response.data || {})
        this.user = user
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
      return axios.post(`/auth/user/${action}/enable`, [user.username])
        .then(response => {
          console.log(response.data)
          this.user.state.enable = !user.state.enable
        })
        .catch(this.catch)
    },
    reset_pass () {
      return axios.get(
        `/auth/reset_pass/${encodeURIComponent(this.username)}`
      ).then(this.done).catch(this.catch)
    },
    set_email () {
      return axios.post(
        '/auth/set_email', {
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
