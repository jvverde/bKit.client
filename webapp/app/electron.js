'use strict'

const electron = require('electron')
const path = require('path')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const Tray = electron.Tray
const Menu = electron.Menu

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

function createWindow () {
  /**
   * Initial window options
   */
  mainWindow = new BrowserWindow({
    height: 600,
    width: 800
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

  console.log('mainWindow opened')
}

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

function createRecoveryWindow() {
  const win = new BrowserWindow({
    width: 1024,
    height: 768,
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
}

function openRecovery(menuItem, browserWindow, event) {
  mainWindow = createRecoveryWindow()
}

function exitApp() {
    app.quit();
}

app.on('ready', () => {
  createWindow()
  tray = new Tray('app/icons/logo/bak.png')
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Recovery', type: 'normal', click: openRecovery },
    { label: 'Backup', type: 'normal' },
    { label: 'Exit', type: 'normal', click: exitApp }
  ])
  tray.setToolTip('Back me up')
  tray.setContextMenu(contextMenu)
});