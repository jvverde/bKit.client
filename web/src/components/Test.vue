<template>
  <q-list highlight>
    <q-list-header>Syslog</q-list-header>
    <q-item v-for="msg in messages" :key="msg">
      <q-item-main>
        {{msg}}
      </q-item-main>
    </q-item>
  </q-list>
</template>

<script>

import {
  QList,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink
} from 'quasar'

export default {
  name: 'test',
  components: {
    QList,
    QListHeader,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide,
    QSideLink
  },
  data () {
    return {
      ws: undefined,
      messages: []
    }
  },
  computed: {
  },
  methods: {
  },
  mounted () {
    this.ws = new WebSocket('ws://localhost:9800')
    this.ws.onerror = (err) => console.log(err)
    this.ws.onopen = (msg) => console.log('WS Open:', msg)
    this.ws.onmessage = (msg) => {
      console.log('Msg: ', msg)
      this.messages.push(msg.data)
    }
    this.ws.onclose = (e) => console.log('WS Closed: ', e)
  },
  beforeDestroy () {
    this.ws = undefined
  }
}
</script>

<style lang="stylus">
</style>
