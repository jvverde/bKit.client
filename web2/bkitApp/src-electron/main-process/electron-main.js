import {
  app,
  BrowserWindow,
  Tray,
  clipboard,
  ipcMain,
  shell,
  Menu
} from 'electron'
import path from 'path'
import fs from 'fs'
import os from 'os'

/**
 * Set `__statics` path to static files in production;
 * The reason we are setting it here is that the path needs to be evaluated at runtime
 */
if (process.env.PROD) {
  global.__statics = require('path').join(__dirname, 'statics').replace(/\\/g, '\\\\')
}

const settingsDir = path.join(app.getPath('userData'), 'bKit')

const settingsFile = path.join(settingsDir, 'settings.json')

global.settings = {
  window: {
    width: 1200,
    height: 600
  },
  server: {
    address: '',
    port:8088
  }
}

if (fs.existsSync(settingsFile)) {
  console.log('Read setting from', settingsFile)
  try {
    const file = fs.readFileSync(settingsFile)
    Object.assign(global.settings, JSON.parse(file))
  } catch (e) {
    console.error('Error:', e)
  }
}

let mainWindow
let tmp = process.env.tmp || os.tmpdir() || '/tmp'
let downloadListeners = []

function createWindow () {
  /**
   * Initial window options
   */
  mainWindow = new BrowserWindow({
    height: global.settings.window.height,
    width: global.settings.window.width,
    useContentSize: true
  })

  mainWindow.loadURL(process.env.APP_URL)

  mainWindow.on('closed', () => {
    mainWindow = null
  })

  let downloadDir = app.getPath('downloads') || tmp
  console.log('downloads to', downloadDir)
  mainWindow.webContents.session.on('will-download', (event, item, webContents) => {
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
  mainWindow.webContents.on('new-window', (event, url) => {
    event.preventDefault()
    console.log("Handing off to O/S: " + url)
    shell.openExternal(url)
  })
  mainWindow.on('resize', (e) => {
    const [w, h] = mainWindow.getSize()
    global.settings.window.height = h
    global.settings.window.width = w
  })
  mainWindow.onbeforeunload = (e) => {
    console.log('before unload')
    downloadListeners = []
    e.returnValue = false
  }
}

function openRecovery(menuItem, browserWindow, event) {
  createWindow()
}

function exitApp() {
    app.quit();
}

ipcMain.on('register', (event, arg) => {
  downloadListeners.find(x => x.channel === arg) || downloadListeners.push({receiver:event.sender, channel: arg})
  event.sender.send(arg, 'done register done for channel:' + arg)
})

ipcMain.on('clear', () => {
  console.log('clear')
  downloadListeners = []
})

ipcMain.on('debug', (event, arg) => {
  mainWindow.webContents.openDevTools()
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow()
  }
})

app.on('before-quit', () => {
  try {
    fs.existsSync(settingsDir) || fs.mkdirSync(settingsDir)
    const json = JSON.stringify(global.settings)
    fs.writeFileSync(settingsFile, json, 'utf8')
    console.log('Settings saved')
  } catch (e) {
    console.error(e)
  }
})

app.on('ready', () => {
    const image = clipboard.readImage()
    console.log(path.join(__statics, '/my/someFile.txt'))
    createWindow()
    let tray = new Tray(image)
    const contextMenu = Menu.buildFromTemplate([
      { label: 'Recovery', type: 'normal', click: openRecovery },
      { label: 'Backup', type: 'normal' },
      { label: 'Exit', type: 'normal', click: exitApp }
    ])
    tray.setToolTip('Back me up')
    tray.setContextMenu(contextMenu)
    console.log('I am ready')
    }
)