export default [
  {
    path: '/',
    name: 'home',
    component: require('components/Server')
  },
  {
    path: '/init',
    name: 'Init-page',
    component: require('components/Console/Init')
  },
  {
    path: '/computers',
    name: 'Computers-page',
    component: require('components/Computers')
  },
  {
    path: '/backup/:computer/:disk',
    name: 'Backups-page',
    component: require('components/Backup')
  },
  {
    path: '/local/disks',
    name: 'Local-disks',
    component: require('components/Local/Disks')
  },
  {
    path: '*',
    redirect: '/'
  }
]
