import * as types from '../mutation-types'

const state = {
  include: [],
  exclude: []
}
function rmfrom (e, a) {
  const index = (a || []).lastIndexOf(e)
  if (index !== -1) a.splice(index, 1)
}
const mutations = {
  [types.INCBACKUPDIR] (state, dir) {
    rmfrom(dir, state.exclude)
    if (state.include.lastIndexOf(dir) === -1) state.include.push(dir)
  },
  [types.EXCBACKUPDIR] (state, dir) {
    rmfrom(dir, state.include)
    if (state.exclude.lastIndexOf(dir) === -1) state.exclude.push(dir)
  },
  [types.RMBACKUPDIR] (state, dir) {
    rmfrom(dir, state.include)
    rmfrom(dir, state.exclude)
  }
}

export default {
  state,
  mutations
}
