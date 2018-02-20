<template>
  <q-modal v-model="show">
    <q-btn color="primary" @click="$emit('close')" label="Close" />
  </q-modal>
</template>

<script>
export default {
  name: 'newServer',
  data () {
    return {
    }
  },
  computed: {
    show () {
      return this.open
    }
  },
  props: ['open']
}
</script>

<style>
</style>
