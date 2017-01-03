export const mainCounter = state => state.counters.main
export const server = state => state.server.address
export const port = state => state.server.port
export const url = state => {
  let {address, port} = state.server
  if (typeof address === 'string' && typeof port === 'number') {
    return 'http://' + address + ':' + port + '/'
  } else if (typeof address === 'string') {
    return 'http://' + address + '/'
  } else {
    return '/'
  }
}
