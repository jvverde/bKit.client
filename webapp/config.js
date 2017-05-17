'use strict'

const path = require('path')

let config = {
  // Name of electron app
  // Will be used in production builds
  name: 'bKit',

  // Use ESLint (extends `standard`)
  // Further changes can be made in `.eslintrc.js`
  eslint: true,

  // webpack+-dev-server port
  port: 9080,

  // electron-packager options
  // Docs: https://simulatedgreg.gitbooks.io/electron-vue/content/docs/building_your_app.html
  building: {
    arch: 'x64,ia32',
    asar: true,
    dir: path.join(__dirname, 'app'),
    icon: path.join(__dirname, 'app/icons/transparent/256x256_transp'),
    ignore: /\b(node_modules|src|index\.ejs|icons)\b/,
    // ignore: /\b(node_modules\/(?!electron|electron-download|extract-zip)|src|index\.ejs|icons)\b/,
    // ignore: /\b(node_modules\/(?!conf|dot-prop|electron-config|env-paths|find-up|is-obj|minimist|mkdirp|path-exists|pinkie|pinkie-promise|pkg-up).*|src|index\.ejs|icons)\b/,
    out: path.join(__dirname, 'builds'),
    overwrite: true,
    platform: process.env.PLATFORM_TARGET || 'all'
  }
}
config.building.name = config.name

module.exports = config
