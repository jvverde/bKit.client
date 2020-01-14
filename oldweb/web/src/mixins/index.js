import { Notify } from 'quasar'

function show (msg) {
  Notify.create({
    message: msg,
    timeout: 3000
  })
}

export const myMixin = {
  methods: {
    show: msg => show(msg),
    done: response => show(response.data.msg || 'done'),
    catch: e => {
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
  }
}
