import * as types from '../mutation-types'

const state = {
  include: [],
  exclude: []
}

const mutations = {
  [types.INCBACKUPDIR] (state, dir) {
    state.include.push(dir)
  },
  [types.EXCBACKUPDIR] (state, dir) {
    state.exclude.push(dir)
  },
  [types.RMBACKUPDIR] (state, dir) {
    let index = state.include.lastIndexOf(dir)
    if (index !== -1) {
      state.include.splice(index, 1)
    }
    index = state.exclude.lastIndexOf(dir)
    if (index !== -1) {
      state.exclude.splice(index, 1)
    }
  }
}

export default {
  state,
  mutations
}
