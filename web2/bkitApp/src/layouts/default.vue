<template>
  <q-layout view="hHh LpR fFf">
    <q-layout-header>
      <q-toolbar color="primary" glossy>
        <q-btn flat dense round @click="leftDrawerOpen = !leftDrawerOpen">
          <q-icon name="menu" />
        </q-btn>
        <q-toolbar-title>
          bKit App
          <div slot="subtitle">Running on Quasar v{{ $q.version }}</div>
        </q-toolbar-title>
      </q-toolbar>
    </q-layout-header>

    <q-layout-drawer v-model="leftDrawerOpen" content-class="bg-grey-2">
      <q-list no-border link inset-delimiter>
        <q-list-header>
          <bkitlogo class="logo"></bkitlogo>
        </q-list-header>
        <q-item @click.native="openURL('http://quasar-framework.org')">
          <q-item-side icon="school" />
          <q-item-main label="Docs" sublabel="quasar-framework.org" />
        </q-item>
        <q-item @click.native="openURL('https://github.com/quasarframework/')">
          <q-item-side icon="code" />
          <q-item-main label="GitHub" sublabel="github.com/quasarframework" />
        </q-item>
        <q-item @click.native="openURL('http://forum.quasar-framework.org')">
          <q-item-side icon="record_voice_over" />
          <q-item-main label="Forum" sublabel="forum.quasar-framework.org" />
        </q-item>
        <q-item @click.native="$router.replace({ name: 'users' })">
          <q-item-side icon="fa fa-users" />
          <q-item-main label="Users" sublabel="Management" />
        </q-item>
        <q-item @click.native="$router.replace({ name: 'alerts' })">
          <q-item-side icon="fa fa-envelope" />
          <q-item-main label="Alerts" sublabel="@bkit" />
        </q-item>
      </q-list>
<!--       <q-side-link item to="/test" exact>
        <q-item-main label="About" />
      </q-side-link>
      <q-side-link item to="/users">
        <q-item-main label="Users" />
      </q-side-link>
      <q-side-link item to="/groups">
        <q-item-main label="Groups" />
      </q-side-link>
      <q-side-link item to="/remote/computers">
        <q-item-main label="Backups" />
      </q-side-link> -->

    </q-layout-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { openURL } from 'quasar'

export default {
  name: 'LayoutDefault',
  data () {
    return {
      leftDrawerOpen: false
    }
  },
  methods: {
    openURL
  }
}
</script>

<style>
</style>
