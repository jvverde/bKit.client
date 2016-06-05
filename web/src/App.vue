<template>
  <div id="app">
    <computers name="Maria"></computers>
  </div>
</template>

<script>
  import Computers from './components/Computers'

  export default {
    components: {
      Computers
    }
  }
</script>

<style>
  html {
    height: 100%;
  }

  body {
    display: flex;
    align-items: left;
    justify-content: left;
    color: #2c3e50;
    font-family: Source Sans Pro, Helvetica, sans-serif;
    font-size: 12pt;
    text-align: center;
  }

  a {
    color: #42b983;
    text-decoration: none;
  }

  .tree{
    text-align: left;    
  }
  .tree ul,
  .tree li
  {
      padding: 0;
      margin: 0;
      list-style: none;
  }
  .tree ul{
    margin-left: .5em;
    position:relative;
  }
  .tree ::before{
    border-width: 0;
    border-style: dotted;
    border-color: #AA3;
    position:absolute;
    display:block;
    content:"";
  }
  .tree ul::before {
    content:"";
    width:0;
    top:0;
    bottom:.7em;            /* (line-height/2) */
    left:0;
    border-left-width:1px;
  }
  .tree li {
    margin:0;
    padding:0 1em;          /* indentation = .5em */
    line-height:1.4em;  
    position:relative;
    cursor: pointer;
  }
  .tree li::before {
    width:.9em;             /* 90% of indentation */
    height:0;
    border-top-width:1px;
    margin-top:-1px;        /* border top width */
    top:.7em;               /* (line-height/2) */
    left:0;
  }
</style>
