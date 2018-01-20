function defaultSession () {
  return Object.assign({}, {
    logged: false,
    user: '',
    token: ''
  })
}
function defaultServer () {
  return {
    session: defaultSession(),
    name: '',
    $http: null
  }
}
export default {
  namespaced: true,
  state: {
    servers: {},
    currentServer: defaultServer ()
  },
  getters: {
    session: state => state.currentServer.session,
    logged: state => state.currentServer.session.logged,
    user: state => state.currentServer.session.user,
    token: state => state.currentServer.session.token,
    servername: state => state.currentServer.name,
    servers: state => Object.keys(state.servers).sort()
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
      if (state.currentServer.name) {
        state.servers[state.currentServer.name] = state.currentServer
      }
    },
    load_server (state, name) {
      state.currentServer = state.servers[name] = state.servers[name] || defaultServer ()
    }
    create_server (state, { name, axios }) {
      // teste
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
    server ({ state, commit }, { name, axios }) {
      commit('save_server', name)
      commit('load_server', name)
    }
  }
}
