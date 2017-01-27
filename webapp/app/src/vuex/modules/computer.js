import * as types from '../mutation-types'

const state = {
  fullname: '',
  name: '',
  domain: '',
  uuid: ''
}

const mutations = {
  [types.SETCOMPUTERNAME] (state, id) {
    state.id = id
    const comps = (id || '').split('.')
    state.uuid = comps.pop()
    state.name = comps.shift()
  }
}

export default {
  state,
  mutations
}
