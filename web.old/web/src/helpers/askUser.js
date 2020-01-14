import {Dialog} from 'quasar'

export default function (p) {
  return new Promise((resolve) => {
    Dialog.create({
      title: p.title,
      message: p.message,
      progress: p.progress,
      noBackdropDismiss: true,
      noEscDismiss: true,
      buttons: [
        {
          label: 'No',
          handler: () => resolve('NO')
        },
        {
          label: 'Yes',
          handler: () => resolve('YES')
        }
      ]
    })
  })
}
