import Vue from 'vue'
import VueRouter from 'vue-router'
import store from 'src/store'
import Vuex from 'vuex'

Vue.use(Vuex)

Vue.use(VueRouter)

function load (component) {
  // '@' is aliased to src/components
  return () => import(`@/${component}.vue`)
}

let router = new VueRouter({
  /*
   * NOTE! VueRouter "history" mode DOESN'T works for Cordova builds,
   * it is only to be used only for websites.
   *
   * If you decide to go with "history" mode, please also open /config/index.js
   * and set "build.publicPath" to something other than an empty string.
   * Example: '/' instead of current ''
   *
   * If switching back to default "hash" mode, don't forget to set the
   * build publicPath back to '' so Cordova builds work again.
   */

  mode: 'hash',
  scrollBehavior: () => ({ y: 0 }),

  routes: [
    {
      path: '/',
      component: load('Layout'),
      children: [
        {
          path: 'users',
          component: load('Users/List'),
          meta: { requiresAuth: true }
        },
        {
          path: 'test',
          component: load('Test')
        },
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
          path: 'new_pass',
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
              path: 'view/:username',
              name: 'userview',
              props: true,
              component: load('User/View')
            }
          ]
        }
      ]
    },
    // Always leave this last one
    { path: '*', component: load('Error404') } // Not found
  ]
})

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    // this route requires auth, check if logged in
    // if not, redirect to login page.
    // if (!auth.loggedIn()) {
    if (!store.getters['auth/logged']) {
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else {
      next()
    }
  } else {
    next() // make sure to always call next()!
  }
})

export default router
