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
    path: '*',
    redirect: '/'
  }
]
