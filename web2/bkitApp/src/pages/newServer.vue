<template>
  <q-modal ref="basicModal">
    <q-btn color="primary" @click="open = false" label="Close" />
  </q-modal>
</template>

<script>
export default {
  name: 'newServer',
  data () {
    return {
      open: true
    }
  }
}
</script>

<style>
</style>
