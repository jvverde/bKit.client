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
    h1{
      display: flex;
      margin: 0;
      margin-top: -10px;
      font-size: 2em;
    }
    .i{
      color:$bkit-color
    }
  }
</style>

<template>
  <header>
    <img class="logo" src="./assets/00-Logotipo/64x64.png">
    <h1>bK<span class="i">i</span>t</h1>
  </header>
</template>

<script>
  export default {
    name: 'bkitlogo'
  }
</script>
