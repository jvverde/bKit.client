<style lang="scss">

  * {
    margin: 0;
    padding: 0;
  }

  html,
  body { 
    height: 100%; 
    width: 100%;
  }

  body {
    align-items: center;
    display: flex;
    font-family: Helvetica, sans-serif;
    justify-content: center;
    text-align: center;
    .main{
      width: 100%;
    }
  }
  header>img{
    float:left;
  }

</style>

<template>
  <div class="main">
    <header>
      <img class="logo" src="./assets/00-Logotipo/64x64.png">
      <h1>bK<span style="color:#67a9fb">i</span><span style="color:#7fff00">t</span></h1>
    </header>
    <router-view></router-view>
  </div>
</template>

<script>
/*  import store from 'src/vuex/store'

  export default {
    store
  }*/
</script>
