export default {
  namespaced: true,
  state: {
    location: {}
  },
  getters: {
    getLocation: state => state.location
  },
  mutations: {
    setLocation (state, value) {
      state.location = value
    }
  },
  actions: {
  }
}
