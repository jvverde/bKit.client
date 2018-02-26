import { Notify } from 'quasar'

export function defaultName () {
  return 'A.' + Math.random().toString(36).substr(2, 9)
}

export function notify (e) {
  let msg = e.toString()
  if (e.response instanceof Object &&
    e.response.data instanceof Object) {
    msg = `<small>${msg}</small><br/><i>${e.response.data.msg}</i>`
  }
  Notify.create({
    message: msg,
    timeout: 10000
  })
}
