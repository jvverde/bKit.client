export const address = state => state.server.address
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
export const computer = state => state.computer
export const server = state => state.server
export const location = state => state.files.location
