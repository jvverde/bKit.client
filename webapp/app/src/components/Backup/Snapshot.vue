<template>
  <div>
    <directory class="root"
      :location="{computer:computer, disk:disk, snapshot:id, path:'/'}">
    </directory> 
  </div>
</template>

<script>
  import Directory from './Directory'

  const requiredString = {
    type: String,
    required: true,
    validator: function (w) {
      return w.length > 0
    }
  }

  export default {
    name: 'snapshot',
    props: {
      computer: requiredString,
      disk: requiredString,
      id: requiredString
    },
    components: {
      Directory
    }
  }
</script>

<style scoped>

</style>
