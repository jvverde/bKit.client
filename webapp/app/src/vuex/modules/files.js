import * as types from '../mutation-types'

const state = {
  path: '/'
}

const mutations = {
  [types.SETPATH] (state, path) {
    state.path = path
  }
}

export default {
  state,
  mutations
}
