let wsList = {}
export function create (url) {
  let ws = new WebSocket(url)
  ws.onclose = () => remove(url)
  return (wsList[url] = ws)
}
export function remove (url) {
  delete wsList[url]
}
export function get (url) {
  return wsList[url]
}
