import { Toast } from 'quasar'

export const myMixin = {
  methods: {
    done (response) {
      let msg = response.data.msg || 'done'
      Toast.create.positive({
        html: msg,
        timeout: 3000
      })
    },
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
