import {
  app,
  BrowserWindow,
  ipcMain
} from 'electron'
import os from 'os'
/**
 * Set `__statics` path to static files in production;
 * The reason we are setting it here is that the path needs to be evaluated at runtime
 */
if (process.env.PROD) {
  global.__statics = require('path').join(__dirname, 'statics').replace(/\\/g, '\\\\')
}

let mainWindow
let tmp = process.env.tmp || os.tmpdir() || '/tmp'
let downloadListeners = []

console.log('tmp directory is ', tmp)

function createMainWindow () {
  /**
   * Initial window options
   */
  mainWindow = new BrowserWindow({
    width: 1000,
    height: 600,
    useContentSize: true
  })

  mainWindow.loadURL(process.env.APP_URL)

  mainWindow.on('closed', () => {
    mainWindow = null
    app.quit()
  })
}

function interceptDownload (window) {
  let downloadDir = app.getPath('downloads') || tmp
  console.log('By default downloads go to ', downloadDir)

  window.webContents.session.on('will-download', (event, item, webContents) => {
    // Set the save path, making Electron not to prompt a save dialog.
    console.log('on download')
    item.setSavePath(`${downloadDir}/${item.getFilename()}`)
    item.on('updated', (event, state) => {
      if (state === 'interrupted') {
        console.log('Download is interrupted but can be resumed')
      } else if (state === 'progressing') {
        if (item.isPaused()) {
          console.log('Download is paused')
        } else {
          console.log(`Received bytes: ${item.getReceivedBytes()}`)
        }
      }
    })
    item.once('done', (event, state) => {
      if (state === 'completed') {
        console.log(`Download successfully: ${item.getFilename()} in path ${item.getSavePath()}`)
        console.log(`${item.getMimeType()}`)
        downloadListeners.forEach( (listener) => {
          listener.receiver.send(listener.channel, {
            type: 'download',
            fullpath: `${item.getSavePath()}`,
            filename: `${item.getFilename()}`,
            mimetype: `${item.getMimeType()}`,
            disposition: `${item.getContentDisposition()}`
          })
        })
      } else {
        console.log(`Download failed: ${state}`)
      }
    })
  })
}

app.on('ready', createMainWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (mainWindow === null) {
    createMainWindow()
  }
})

function createChildWindow (address) {
  /**
   * Initial window options
   */
  let win = new BrowserWindow({
    width: 1000,
    height: 600,
    useContentSize: true,
  })

  win.loadURL(address)

  win.on('closed', () => {
    win = null
  })
  
  interceptDownload(win)
  return win
}

ipcMain.on('openUrl', (event, arg) => {
  console.log('open: ' + arg)
  // downloadListeners.find(x => x.channel === arg) || downloadListeners.push({receiver:event.sender, channel: arg})
  createChildWindow(arg)
  event.sender.send(arg, 'done openurl done for channel:' + arg)
})
