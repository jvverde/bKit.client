import { Toast } from 'quasar'

function show (msg) {
  Toast.create.positive({
    html: msg,
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
      Toast.create.negative({
        html: msg,
        timeout: 10000
      })
    }
  }
}
