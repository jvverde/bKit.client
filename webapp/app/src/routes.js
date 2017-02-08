export default [
  {
    path: '/',
    name: 'home',
    component: require('components/Server')
  },
  {
    path: '/help',
    name: 'help-page',
    component: require('components/LandingPageView')
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
    path: '*',
    redirect: '/'
  }
]
