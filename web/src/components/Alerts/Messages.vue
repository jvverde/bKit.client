<template>
  <q-list class="absolute-top" dense no-border>
    <q-list-header class="text-center">Messages</q-list-header>
    <q-item
      link
      v-for="(msg, index) in messages"  
      :key="index"
    >
      <q-item-main :label="msg">

      </q-item-main>
      <q-item-side 
        right 
        icon="delete forever" 
        color="negative" 
        @click="remove(index)"
      />
    </q-item>
  </q-list>
</template>

<script>
// import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  QBtn,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink
} from 'quasar'

export default {
  name: 'form',
  components: {
    QBtn,
    QListHeader,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide,
    QSideLink
  },
  data () {
    return {
    }
  },
  props: {
    messages: {
      type: Array,
      required: true
    }
  },
  computed: {
  },
  mixins: [myMixin],
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
