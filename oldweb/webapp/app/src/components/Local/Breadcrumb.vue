<template>
  <ul class="breadcrumb">
    <li>
      <span>
       <router-link to="/" class="icon is-small"><i class="fa fa-home">Home</i></router-link>
      </span>
    </li>
  </ul>
</template>

<script>
  export default {
    name: 'breadcrumb',
    data () {
      return {
      }
    },
    computed: {
    },
    props: [],
    components: {
    },
    created: function () {
    },
    methods: {
    }
  }
</script>

<style scoped lang="scss">
  @import "../../breadcrumb.scss";
</style>
