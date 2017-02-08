<style scoped lang="scss">
  header{
    display: flex;
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
  }
</style>

<template>
  <header>
    <img class="logo" src="./assets/00-Logotipo/64x64.png">
    <h1>bK<span style="color:#67a9fb">i</span><span style="color:#7fff00">t</span></h1>
  </header>
</template>

<script>
  export default {
    name: 'bkitlogo'
  }
</script>
