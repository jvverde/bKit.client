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

  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
