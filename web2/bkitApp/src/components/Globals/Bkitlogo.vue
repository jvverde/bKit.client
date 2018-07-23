<template>
  <header>
    <router-link to="/">
      <img src="~assets/bkit-logo.svg" class="logo">
    </router-link>
    <h1>bK<span class="i">i</span>t</h1>
    <i v-if="admin !== true"
      :title="alert"
      class="fa fa-exclamation-triangle alert" aria-hidden="true">
    </i>
  </header>
</template>

<script>
const isElectron = () => typeof process !== 'undefined' &&
  typeof process.versions !== 'undefined' &&
  typeof process.versions.node !== 'undefined'

let exec = null
if (isElectron()) {
  // exec = require('child_process').exec
}
let init = true
export default {
  name: 'bkitlogo',
  data () {
    return {
      admin: (process.getuid && process.getuid() === 0) || false,
      alert: process.platform === 'win32'
        ? "You don't have full access. Run as Administrator"
        : "You don't have full access. Run with sudo"
    }
  },
  created () {
    if (process.platform === 'win32' && exec !== null) {
      exec('NET SESSION', (err) => {
        if (err) {
          this.admin = false
          init && this.$notify.warning({
            title: 'Missing privilegies',
            message: 'You should run as Administrator in order to have full access',
            customClass: 'message warning',
            duration: 5000
          })
          init = false
        } else {
          this.admin = true
        }
      })
    } else {
      this.admin = true
    }
  }
}
</script>

<style scoped lang="scss">
  @import "src/scss/config.scss";
  header{
    display: flex;
    flex-shrink:0;
    flex-direction:column;
    justify-content: flex-start;
    align-items: flex-start;
    margin-left: 10px;
    margin-right: 10px;
    position: relative;
    overflow: hidden;
    h1{
      display: flex;
      margin: 0;
      font-size: inherit;
    }
    .i{
      color:$bkit-color
    }
    .alert{
      position: absolute;
      top:1px;
      left:0;
    }
    .logo {
      position: absolute;
      width: 100%;
      height: 100%;
      bottom: 0;
      right: 0;
    }
  }
</style>
