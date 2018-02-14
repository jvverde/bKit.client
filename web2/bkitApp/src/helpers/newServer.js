import store from 'src/store'
import {QAlert, Dialog} from 'quasar'
import {defaultName} from 'src/helpers/utils'

export default function newServer (title) {
  return new Promise((resolve) => {
    Dialog.create({
      title: title || 'Server Address',
      form: {
        name: {
          type: 'text',
          label: 'Name <small>(<i>must be uniq</i>)</small>',
          model: defaultName()
        },
        address: {
          type: 'text',
          label: 'IP/Name Address',
          model: ''
        },
        port: {
          type: 'text',
          label: 'Port Number',
          model: ''
        }
      },
      buttons: [
        {
          label: 'Cancel',
          handler: () => resolve(null)
        },
        {
          label: 'Apply',
          preventClose: true,
          handler: (data, close) => {
            const url = `http://${data.address}:${data.port}`
            store.dispatch('auth/addServer', {
              url: url,
              name: data.name
            }).then(() => {
              close()
              resolve(url)
            }).catch(e => {
              QAlert.create.negative({
                html: e.toString(),
                timeout: 10000
              })
            })
          }
        }
      ]
    })
  })
}
