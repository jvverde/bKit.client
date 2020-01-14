export default {
  namespaced: true,
  state: {
    messages: []
  },
  getters: {
    messages: state => state.messages
  },
  mutations: {
    push (state, value) {
      state.messages.push(value)
    },
    remove (state, index) {
      state.messages.splice(index, 1)
    },
    clean (state) {
      state.messages = []
    }
  },
  actions: {
  }
}
