function loadComponent (c) {
  return () => import(`components/${c}.vue`)
}
function loadPage (p) {
  return () => import(`pages/${p}.vue`)
}
function loadLayout (l) {
  return () => import(`layouts/${l}.vue`)
}

const subpath = [
  {
    path: '',
    component: loadPage('index')
  },
  {
    path: 'signin',
    name: 'signin',
    component: loadComponent('Auth/Signin')
  },
  {
    path: 'signup',
    name: 'signup',
    component: loadComponent('Auth/Signup')
  },
  {
    path: 'reset_pass',
    component: loadComponent('Auth/Reset')
  },
  {
    path: 'new_pass/:username',
    props: true,
    component: loadComponent('Auth/Password')
  },
  {
    path: 'alerts',
    component: loadComponent('Alerts/Alerts'),
    name: 'alerts'
  },
  {
    path: 'users',
    name: 'users',
    component: loadComponent('Users/List'),
    meta: { requiresAuth: true }
  },
  {
    path: 'groups',
    name: 'groups',
    component: loadComponent('Groups/List'),
    meta: { requiresAuth: true }
  },
  {
    path: 'remote',
    name: 'backups',
    component: loadPage('Remote'),
    children: [
      {
        path: 'computers/:selected*',
        name: 'remote-computers',
        props: true,
        component: loadComponent('Remote/Computers')
      },
      {
        path: 'backup/:computer/:disk',
        name: 'remote-disk',
        props: true,
        component: loadComponent('Remote/Backup')
      }
    ]
  },
  {
    path: 'show',
    component: loadComponent('Show')
  },
  {
    path: 'user',
    meta: { requiresAuth: true },
    component: loadComponent('User/Layout'),
    children: [
      {
        path: 'view/:name',
        name: 'userview',
        props: true,
        component: loadComponent('User/View')
      }
    ]
  }
  /*
  {
    path: 'test',
    component: loadComponent('Test')
  },
  {
    path: 'new_pass/:username',
    props: true,
    component: loadComponent('Auth/Password')
  },
  {
    path: 'local',
    name: 'local',
    component: loadComponent('Local/loadLayout'),
    children: [
      {
        path: 'disks',
        name: 'local-disks',
        component: loadComponent('Local/Disks')
      }
    ]
  },
  */
]

export default [
  {
    path: '/',
    component: loadLayout('default'),
    children: subpath
  },
  { // Always leave this as last one
    path: '*',
    component: loadPage('404')
  }
]
