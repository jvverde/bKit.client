export default [
  {
    path: '/',
    name: 'server',
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
    path: '/backups',
    name: 'Backups-page',
    component: require('components/Computers')
  },  {
    path: '*',
    redirect: '/'
  }
]
