import * as types from '../mutation-types'

const state = {
  include: [],
  exclude: []
}
function rmfrom (a = [], entry) {
  const index = a.findIndex(e => e.path === entry.path)
  if (index !== -1) a.splice(index, 1)
}
const mutations = {
  [types.INCBACKUPDIR] (state, entry) {
    rmfrom(state.exclude, entry)
    if (!state.include.find(e => e.path === entry.path)) state.include.push(entry)
  },
  [types.EXCBACKUPDIR] (state, entry) {
    rmfrom(state.include, entry)
    if (!state.include.find(e => e.path === entry.path)) state.exclude.push(entry)
  },
  [types.RMBACKUPDIR] (state, entry) {
    rmfrom(state.include, entry)
    rmfrom(state.exclude, entry)
  }
}

export default {
  state,
  mutations
}
