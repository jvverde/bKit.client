import * as types from './mutation-types'

export const setServerAddress = ({ commit }, addr) => {
  if (typeof addr !== 'string') {
    console.warn('Address must be a string, we got a ' + typeof addr)
  }
  commit(types.SETSERVER, addr)
}

export const setServerPort = ({ commit }, port) => {
  port = 0 | port
  if (port < 0 || port > 65536) {
    console.warn('Port must be between 0 and 65536')
  }
  commit(types.SETPORT, port)
}

export const setComputerName = ({ commit }, name) => {
  commit(types.SETCOMPUTERNAME, name)
}

export const setPath = ({ commit }, path) => {
  commit(types.SETPATH, path)
}
