import { Notify } from 'quasar'

function show (msg) {
  Notify.create({
    message: msg,
    type: 'positive',
    position: 'top-right',
    timeout: 3000
  })
}
function error (msg, detail = '') {
  Notify.create({
    message: msg,
    detail: detail,
    type: 'negative',
    position: 'top-right',
    timeout: 10000,
    actions: [{
      label: 'Dismiss',
      icon: 'cancel',
      handler: () => {}
    }]
  })
}
function notify (arg = {}) {
  Notify.create(arg)
}
export const myMixin = {
  methods: {
    show: msg => show(msg),
    done: response => show(response.data.msg || 'done'),
    error,
    notify,
    catch: e => {
      let msg = e.toString()
      if (e.response instanceof Object && e.response.data instanceof Object) {
        error(msg, e.response.data.msg)
      } else {
        error(msg)
      }
    }
  }
}
