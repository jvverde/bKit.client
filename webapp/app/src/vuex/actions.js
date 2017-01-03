import * as types from './mutation-types'

export const decrementMain = ({ commit }) => {
  commit(types.DECREMENT_MAIN_COUNTER)
}

export const incrementMain = ({ commit }) => {
  commit(types.INCREMENT_MAIN_COUNTER)
}

export const setServerAddress = ({ commit }, addr) => {
  console.log('SetServer:' + addr)
  commit(types.SETSERVER, addr)
}

export const setServerPort = ({ commit }, port) => {
  console.log('SetServerPort:' + port)
  commit(types.SETPORT, port)
}
