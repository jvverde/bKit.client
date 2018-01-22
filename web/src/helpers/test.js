let wsList = {}
export function add (b) {
  a += b
  console.log('a=', a)
}
export function mul (b) {
  a *= b
  console.log('a=', a)
}
export WebSocket (url) => {
  let ws = new WebSocket('url')
  ws.onclose(() => socketClose(url))
  return wsList[url] = ws
}
export socketClose (url) => delete wsList[url]
export getSocket (url) => wsList[url]


