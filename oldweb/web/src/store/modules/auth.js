function defaultSession () {
  return Object.assign({}, {
    logged: false,
    user: '',
    token: ''
  })
}
function defaultServer ({session = defaultSession(), name = '', url = null} = {}) {
  return Object.assign({}, {
    session: session,
    name: name,
    url: url
  })
}
function defaultState () {
  return Object.assign({}, {
    servers: [],
    currentServer: defaultServer()
  })
}
import axios from 'axios'
import {defaultName} from 'src/helpers/utils'

export default {
  namespaced: true,
  state: defaultState(),
  getters: {
    session: state => state.currentServer.session,
    logged: state => state.currentServer.session.logged,
    user: state => state.currentServer.session.user,
    token: state => state.currentServer.session.token,
    servername: state => state.currentServer.name,
    baseURL: state => state.currentServer.url,
    servers: state => state.servers
  },
  mutations: {
    logged (state, value) {
      state.currentServer.session.logged = value
    },
    token (state, token) {
      state.currentServer.session.token = token
    },
    user (state, user) {
      state.currentServer.session.user = user
    },
    session (state, session) {
      state.currentServer.session.user = session.user
      state.currentServer.session.token = session.token
      state.currentServer.session.logged = session.logged
    },
    logout (state) {
      state.currentServer.session.user = ''
      state.currentServer.session.token = ''
      state.currentServer.session.logged = false
    },
    login (state, {user, token}) {
      state.currentServer.session.user = user
      state.currentServer.session.token = token
      state.currentServer.session.logged = true
    },
    save_server (state) {
      let i = state.servers.findIndex(s => s.name === state.currentServer.name)
      if (i >= 0) {
        state.servers[i] = state.currentServer
      } else if (state.currentServer.name) {
        state.servers.push(state.currentServer)
      }
    },
    load_server (state, name) {
      let i = state.servers.findIndex(s => s.name === name)
      let found = i >= 0
      if (found) {
        state.currentServer = state.servers[i]
      }
      return found
    },
    remove_server (state, name) {
      let i = state.servers.findIndex(s => s.name === name)
      let found = i >= 0
      if (found) state.servers.splice(i, 1)
      if (state.currentServer.name === name) {
        state.currentServer = state.servers[0] || defaultServer()
      }
      return found
    },
    add_server (state, server) {
      let i = state.servers.findIndex(s => s.name === server.name)
      if (i < 0) {
        let newServer = defaultServer(server)
        state.currentServer = newServer
        return state.servers.push(newServer)
      }
      return null
    },
    reset (state) {
      state.servers = []
      state.currentServer = defaultServer()
    }
  },
  actions: {
    logged ({ commit }, value) {
      commit('logged', value)
    },
    user ({ commit }, value) {
      commit('user', value)
    },
    token ({ commit }, value) {
      commit('token', value)
    },
    session ({ commit }, session) {
      commit('session', session)
    },
    logout ({ commit }) {
      commit('logout')
    },
    login ({ commit }, data) {
      commit('login', data)
    },
    chgServer ({ commit }, name) {
      commit('save_server')
      commit('load_server', name)
    },
    rmServer ({ commit }, name) {
      commit('remove_server', name)
    },
    addServer ({ commit }, { url, name = defaultName() }) {
      return axios.get(`${url}/info`)
        .then(response => {
          commit('save_server')
          commit('add_server', {
            name: name,
            url: url
          })
        })
    },
    reset ({ commit }) {
      commit('reset')
    }
  }
}
