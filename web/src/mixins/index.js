import { Toast } from 'quasar'

export const myMixin = {
  methods: {
    catch (e) {
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
