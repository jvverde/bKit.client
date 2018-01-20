import axios from 'axios'
import store from 'src/store'
import {Toast, Dialog} from 'quasar'

export default function addServer (title) {
  Dialog.create({
    title: title || 'Server Address',
    form: {
      address: {
        type: 'text',
        label: 'Name/IP Address',
        model: ''
      },
      port: {
        type: 'text',
        label: 'Port Number',
        model: ''
      }
    },
    buttons: [
      'Cancel',
      {
        label: 'Apply',
        handler: data => {
          const server = `http://${data.address}:${data.port}`
          console.log(server)
          axios.get(`${server}/info`)
            .then(response => {
              console.log(response.data)
              store.dispatch('auth/server', server)
            })
            .catch(e => {
              Toast.create.negative({
                html: e.toString(),
                timeout: 10000
              })
            })
        }
      }
    ]
  })
}
