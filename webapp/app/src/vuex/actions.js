import * as types from './mutation-types'

export const setServerAddress = ({ commit }, addr) => {
  commit(types.SETSERVER, addr)
}

export const setServerPort = ({ commit }, port) => {
  commit(types.SETPORT, port)
}

export const setComputerName = ({ commit }, name) => {
  commit(types.SETCOMPUTERNAME, name)
}
