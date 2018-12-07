import * as types from '../mutation-types'

const state = {
  address: null,
  port: null
}

const mutations = {
  [types.SETSERVER] (state, address) {
    state.address = address
  },
  [types.SETPORT] (state, port) {
    state.port = port
  }
}

export default {
  state,
  mutations
}
