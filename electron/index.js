'use strict';

// adds debug features like hotkeys for triggering dev tools and reload
require('electron-debug')();
const {app, Menu, Tray, BrowserWindow} = require('electron')

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
		width: 600,
		height: 400,
		webPreferences: {
			webSecurity: false
		}
	});

	win.loadURL(`file://${__dirname}/recovery/index.html`);
	win.on('closed', onClosed);

	return win;
}

app.on('window-all-closed', () => {
	if (process.platform !== 'darwin') {
		app.quit();
	}
});

app.on('activate', () => {
	console.log('on activate');
	// if (!mainWindow) {
	//  	mainWindow = createMainWindow();
	// }
});

app.on('ready', () => {
	tray = new Tray('assets/logo/bak.png')
	const contextMenu = Menu.buildFromTemplate([
		{ label: 'Recovery', type: 'normal', click: openApp },
		{ label: 'Backup', type: 'normal' }
	])
	tray.setToolTip('Back me up')
	tray.setContextMenu(contextMenu)
});

