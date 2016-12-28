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
    path: '/recovery',
    name: 'Recovery-page',
    component: require('components/Recovery/Computers')
  },
  {
    path: '*',
    redirect: '/'
  }
]
