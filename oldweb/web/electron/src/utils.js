const electron = require('E/electron')
export function isElectron () {
  console.log(process.versions)
  console.log(electron)
  console.log(process.platform)
  return typeof process !== 'undefined' && typeof process.versions.electron !== 'undefined'
}
