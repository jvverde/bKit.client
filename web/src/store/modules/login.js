export default {
  namespaced: true,
  state: {
    session: {
      logged: false,
      user: '',
      token: ''
    }
  },
  getters: {
    session: state => state.session,
    logged: state => state.session.logged,
    user: state => state.session.user,
    token: state => state.session.token
  },
  mutations: {
    logged (state, value) {
      state.session.logged = value
    },
    token (state, token) {
      state.session.token = token
    },
    user (state, user) {
      state.session.user = user
    },
    session (state, session) {
      state.session.user = session.user
      state.session.token = session.token
      state.session.logged = session.logged
    },
    logout (state) {
      state.session.user = ''
      state.session.token = ''
      state.session.logged = false
    },
    login (state, {user, token}) {
      state.session.user = user
      state.session.token = token
      state.session.logged = true
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
    }
  }
}
