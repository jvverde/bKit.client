import * as types from '../mutation-types'

const state = {
  main: 200
}

const mutations = {
  [types.DECREMENT_MAIN_COUNTER] (state) {
    state.main--
  },
  [types.INCREMENT_MAIN_COUNTER] (state) {
    state.main++
  }
}

export default {
  state,
  mutations
}
