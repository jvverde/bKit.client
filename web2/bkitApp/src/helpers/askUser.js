import {Dialog} from 'quasar'

export default function (p) {
  return Dialog.create({
    title: p.title,
    message: p.message,
    noBackdropDismiss: true,
    noEscDismiss: true,
    ok: 'YES',
    cancel: 'NO'
  })
}
