<template>
  <main class="absolute-top">
    <section class="text-center">
      <header>
        Messages
      </header>
      <div>
        <q-btn icon="delete" color="warning" @click="clean">
          All
        </q-btn>
      </div>
    </section>
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
// import {myMixin} from 'src/mixins'

import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'form',
  components: {
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
  // mixins: [myMixin],
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

<style>
</style>
