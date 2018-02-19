<template>
  <q-modal v-model="open">
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
  props: ['open']
}
</script>

<style>
</style>
