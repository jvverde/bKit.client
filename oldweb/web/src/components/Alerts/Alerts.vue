<template>
  <main class="absolute-top">
    <q-card flat class="text-center">
      <q-card-title>
        Messages
      </q-card-title>
      <q-card-actions>
        <q-btn icon="delete" color="warning" @click="clean">
          All
        </q-btn>
      </q-card-actions>
    </q-card>
    <q-list dense no-border>
      <q-item v-for="(entry, index) in messages" :key="index">
        <q-item-main :label="entry.name" :sublabel="entry.data.msg">
        </q-item-main>
        <q-item-side>
          <q-btn icon="delete" flat color="warning" 
            @click="remove(index)"/>
        </q-item-side>
      </q-item>
    </q-list>
  </main>
</template>

<script>
// import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  QCard,
  QCardMain,
  QCardTitle,
  QCardActions,
  QBtn,
  QIcon,
  QCheckbox,
  QList,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink
} from 'quasar'

import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'form',
  components: {
    QCard,
    QCardMain,
    QCardTitle,
    QCardActions,
    QBtn,
    QIcon,
    QCheckbox,
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
      selected: []
    }
  },
  computed: {
    ...mapGetters('alerts', [
      'messages'
    ])
  },
  mixins: [myMixin],
  methods: {
    ...mapMutations('alerts', [
      'remove',
      'clean'
    ])
  },
  mounted () {
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
