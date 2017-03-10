import * as types from '../mutation-types'

const state = {
  location: {}
}

const mutations = {
  [types.SETLOCATION] (state, location) {
    state.location = location
  }
}

export default {
  state,
  mutations
}
