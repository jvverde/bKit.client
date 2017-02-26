'use strict'

const electron = require('electron')
const path = require('path')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const Tray = electron.Tray
const Menu = electron.Menu
const ipcMain = electron.ipcMain
const shell = electron.shell
const clipboard = electron.clipboard
const dialog = electron.dialog
const fs = require('fs')
const {spawnSync} = require('child_process')
const platform = require('os').platform()

if (platform === 'win32') {
  const parentDir = path.resolve(process.cwd(), '..')
  const bash = path.resolve(parentDir,'3rd-party','cygwin','bin','bash.exe')
  if (!fs.existsSync(bash)){
    const setup = `${parentDir}/setup.bat`
    const fd = spawnSync('CMD', ['/C',setup], {cwd: parentDir})
  }
}


let mainWindow
let config = {}
let tray = null

if (process.env.NODE_ENV === 'development') {
  config = require('../config')
  config.url = `http://localhost:${config.port}`
} else {
  config.devtron = false
  config.url = `file://${__dirname}/dist/index.html`
}


const userdata = path.join(app.getPath('userData'), 'bKit')

fs.existsSync(userdata) || fs.mkdirSync(userdata)

const settingsFile = path.resolve(userdata,'settings.json')
global.settings = {
  window: {
    width: 1200,
    height: 800
  },
  server: {
    address: '10.11.0.135',
    port:8088
  }
}

if (fs.existsSync(settingsFile)) {
  try {
    const file = fs.readFileSync(settingsFile)
    Object.assign(global.settings, JSON.parse(file))
  } catch (e) {
    console.error('Error:', e)
  }
}

function createWindow () {
  mainWindow = new BrowserWindow({
    height: global.settings.window.height,
    width: global.settings.window.width,
    webPreferences: {
      webSecurity: false
    }
  })

  mainWindow.loadURL(config.url)

  if (process.env.NODE_ENV === 'development') {
    BrowserWindow.addDevToolsExtension(path.join(__dirname, '../node_modules/devtron'))

    let installExtension = require('electron-devtools-installer')

    installExtension.default(installExtension.VUEJS_DEVTOOLS)
      .then((name) => mainWindow.webContents.openDevTools())
      .catch((err) => console.log('An error occurred: ', err))
  }

  mainWindow.on('closed', () => {
    mainWindow = null
  })

  console.log('The mainWindow is now open')

  let tmp = process.env.tmp || process.env.tmp || '/tmp'
  mainWindow.webContents.session.on('will-download', (event, item, webContents) => {
    // Set the save path, making Electron not to prompt a save dialog.
    console.log('on download')
    let tmp = app.getPath('downloads') || process.env.tmp || process.env.tmp || '/tmp'
    item.setSavePath(`${tmp}/${item.getFilename()}`)
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

  mainWindow.webContents.on('new-window', function(event, url) {
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
let downloadListeners = []
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

//app.on('ready', createWindow)

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
    const json = JSON.stringify(global.settings)
    fs.writeFileSync(settingsFile, json, 'utf8')
  } catch (e) {
    console.error(e)
  }
})

/*function createRecoveryWindow() {
  const win = new BrowserWindow({
    width: 1024,
    height: 768,
    frame: false,
    webPreferences: {
      webSecurity: false
    }
  });
  //win.loadURL(`file://${__dirname}/recovery/index.html`);
  //win.loadURL(`file://${__dirname}/ionic/bKit/www/index.html`);
  //win.webContents.openDevTools();
  win.loadURL('file://10.11.0.135:8088/');
  win.on('closed', () => {
    //win = null
  })
  return win;
}*/

function openRecovery(menuItem, browserWindow, event) {
  //mainWindow = createRecoveryWindow()
  createWindow()
}

function exitApp() {
    app.quit();
}

app.on('ready', () => {
  createWindow()
  console.log('on ready')
  const image = clipboard.readImage()
  tray = new Tray(image)
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Recovery', type: 'normal', click: openRecovery },
    { label: 'Backup', type: 'normal' },
    { label: 'Exit', type: 'normal', click: exitApp }
  ])
  tray.setToolTip('Back me up')
  tray.setContextMenu(contextMenu)
  console.log('I am ready')
});

// console.log('Path:',app.getAppPath());

/*const spawn = require('child_process').spawn;
const ls = spawn('ls', ['-lh', '/usr']);

ls.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

ls.stderr.on('data', (data) => {
  console.log(`stderr: ${data}`);
});

ls.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});*/
