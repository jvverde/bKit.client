import * as types from '../mutation-types'

const state = {
  entries: {}
}

const mutations = {
  [types.SETENTRY] (state, {path, entries}) {
    state.entries[path] = entries
  }
}

const getters = {
  entries: state => state.entries
}

const actions = {
  setEntry: ({ commit }, entry) => {
    commit(types.SETENTRY, entry)
  }
}

export default {
  state,
  mutations,
  getters,
  actions
}
