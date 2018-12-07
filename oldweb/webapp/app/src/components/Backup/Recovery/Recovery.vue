<template>
  <a
    :href="url" title="Recuperar">
    <span class="icon is-small">
      <i class="fa fa-history"></i>
    </span>
  </a>
</template>

<script>
  const requiredURL = {
    type: String,
    required: true,
    validator: function (u) {
      return u.match(/https?:\/\/.+/)
    }
  }

  export default {
    name: 'recovery',
    data () {
      return {
        electron: false
      }
    },
    props: {
      url: requiredURL
    },
    created () {
      if ('$electron' in this) {
        this.electron = true
      }
    },
    methods: {
      download () {
        console.log('download')
      }
    }
  }

</script>

<style scoped>

</style>
