'use strict';

// adds debug features like hotkeys for triggering dev tools and reload
require('electron-debug')();
const {app, Menu, Tray, BrowserWindow, ipcMain} = require('electron')
const config = require('electron-json-config');
console.log('Abri');

ipcMain.on('close-main-window', function () {
	console.log('quit');
 //app.quit();
});

global.server = {
  address: '10.1.2.3',
  port: 8088
}

// prevent window being garbage collected
let mainWindow;
let tray = null

function openApp(menuItem, browserWindow, event) {
	mainWindow = createMainWindow()
}

function onClosed() {
	// dereference the window
	// for multiple windows store them in an array
	mainWindow = null;
}

function createMainWindow() {
	const win = new BrowserWindow({
		width: 1024,
		height: 768,
		webPreferences: {
			webSecurity: false
		}
	});
	//win.loadURL(`file://${__dirname}/recovery/index.html`);
	win.loadURL(`file://${__dirname}/ionic/bKit/www/index.html`);
	win.webContents.openDevTools();
	//win.loadURL('file://10.11.0.135:8088/');
	win.on('closed', onClosed);

	return win;
}

app.on('window-all-closed', () => {
	if (process.platform !== 'darwin') {
		//app.quit();
	}
});

app.on('activate', () => {
	console.log('on activate');
	// if (!mainWindow) {
	//  	mainWindow = createMainWindow();
	// }
});

function exitApp() {
		app.quit();
}

app.on('ready', () => {
	tray = new Tray('assets/logo/bak.png')
	const contextMenu = Menu.buildFromTemplate([
		{ label: 'Recovery', type: 'normal', click: openApp },
		{ label: 'Backup', type: 'normal' },
		{ label: 'Exit', type: 'normal', click: exitApp }
	])
	tray.setToolTip('Back me up')
	tray.setContextMenu(contextMenu)
});

