
function load (component) {
  return () => import(`components/${component}.vue`)
}

export default [
  {
    path: '/',
    component: () => import('layouts/default'),
    children: [
      { path: '', component: () => import('pages/index') },
      {
        path: 'login',
        name: 'login',
        component: load('Auth/Login')
      },
      {
        path: 'signup',
        name: 'signup',
        component: load('Auth/Signup')
      },
      {
        path: 'reset_pass',
        component: load('Auth/Reset')
      },
      {
        path: 'new_pass/:username',
        props: true,
        component: load('Auth/Password')
      },
      {
        path: 'alerts',
        component: load('Alerts/Alerts'),
        name: 'alerts'
      },
      {
        path: 'users',
        name: 'users',
        component: load('Users/List'),
        meta: { requiresAuth: true }
      },
      {
        path: 'groups',
        name: 'groups',
        component: load('Groups/List'),
        meta: { requiresAuth: true }
      },
      {
        path: 'remote',
        name: 'backups',
        component: load('Remote/Layout'),
        children: [
          {
            path: 'computers',
            name: 'remote-computers',
            component: load('Remote/Computers')
          },
          {
            path: 'backup/:computer/:disk',
            name: 'remote-diks',
            props: true,
            component: load('Remote/Backup')
          }
        ]
      } /*
      {
        path: 'test',
        component: load('Test')
      },
      {
        path: 'new_pass/:username',
        props: true,
        component: load('Auth/Password')
      },
      {
        path: 'show',
        component: load('Show')
      },
      {
        path: 'user',
        meta: { requiresAuth: true },
        component: load('User/Layout'),
        children: [
          {
            path: 'view/:name',
            name: 'userview',
            props: true,
            component: load('User/View')
          }
        ]
      },
      {
        path: 'local',
        name: 'local',
        component: load('Local/Layout'),
        children: [
          {
            path: 'disks',
            name: 'local-disks',
            component: load('Local/Disks')
          }
        ]
      },
      */
    ]
  },

  { // Always leave this as last one
    path: '*',
    component: () => import('pages/404')
  }
]
