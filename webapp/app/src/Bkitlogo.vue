<style scoped lang="scss">
  @import "./config.scss";
  header{
    display: flex;
    flex-shrink:0;
    flex-direction:column;
    justify-content: flex-start;
    align-items: flex-start;
    margin-left: 10px;
    margin-right: 10px;
    position: relative;
    h1{
      display: flex;
      margin: 0;
      margin-top: -10px;
      font-size: 2em;
    }
    .i{
      color:$bkit-color
    }
    .alert{
      position: absolute;
      top:1px;
      left:0;
    }
  }
</style>

<template>
  <header>
    <router-link to="/">
      <img class="logo" src="./assets/00-Logotipo/64x64.png">
    </router-link>
    <h1>bK<span class="i">i</span>t</h1>
    <i v-if="admin === false" 
      :title="alert"
      class="fa fa-exclamation-triangle alert" aria-hidden="true">
    </i>
  </header>
</template>

<script>
  const {exec} = require('child_process')
  export default {
    name: 'bkitlogo',
    data () {
      return {
        admin: 5,
        alert: process.platform === 'win32'
          ? "You don't have full access. Run as Administrator"
          : "You don't have full access. Run with sudo"
      }
    },
    methods: {
      created () {
        process.platform === 'win32' && exec('NET SESSION', (err) => {
          if (err) {
            this.admin = false
            this.$notify.warning({
              title: 'Missing privilegies',
              message: 'You should run as Administrator in order to have full access',
              customClass: 'message warning',
              duration: 0
            })
          } else {
            this.admin = true
          }
        })
      }
    }
  }
</script>
