import { Notify } from 'quasar'

function show (msg) {
  Notify.create({
    message: msg,
    type: 'positive',
    position: 'top-right',
    timeout: 3000
  })
}

export const myMixin = {
  methods: {
    show: msg => show(msg),
    done: response => show(response.data.msg || 'done'),
    catch: e => {
      let msg = e.toString()
      let detail = ''
      if (e.response instanceof Object && e.response.data instanceof Object) {
        detail = e.response.data.msg
      }
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
  }
}
