export default [
  {
    path: '/',
    name: 'Home-page',
    component: require('components/Home')
  },
  {
    path: '/server',
    name: 'Setserver-page',
    component: require('components/Server')
  },
  {
    path: '/smtp',
    name: 'Smtp-page',
    component: require('components/Smtp')
  },
  {
    path: '/update',
    name: 'Update-page',
    component: require('components/Update')
  },
  {
    path: '/init',
    name: 'Init-page',
    component: require('components/Init')
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
    path: '/job',
    name: 'Job-page',
    component: require('components/Local/Job')
  },
  {
    path: '*',
    redirect: '/'
  }
]
