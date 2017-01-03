<template>
  <ul class="breadcrumb">
    <li>
      <span>
       <router-link to="/">Start</router-link>
      </span>
    </li>
    <li>
      <span>
        <router-link to="/computers">{{computer}}</router-link>
      </span>
    </li>
    <li>
      <span>
        <router-link :to="{ 
          name: 'Backups-page',
          params: { 
            computer: computer,
            disk:disk 
          }}">
          {{disk}}
        </router-link>
      </span>
    </li>
    <li>
      <span>
        <a>{{snap}}</a>
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
    props: ['computer', 'disk', 'snap'],
    components: {
    },
    created: function () {
      console.log('Breadcrumbs')
      console.log(this.$store.getters.server)
      console.log(this.$store.getters.port)
      console.log(this.$store.getters.url)
    },
    methods: {

    }
  }
</script>

<style scoped lang="scss">
  $arrowidth: 1em;
  $arrowstrech:2;
  $arrowcolor:lightgray;
  $arrowcolorhover: rgba(230, 230, 230, 0.9);
  $arrowborderradius: 4px;

  ul.breadcrumb {
    list-style: none; 
    margin-left: $arrowidth;
    display: flex;
    flex-wrap:wrap;
    font-size: 8pt;
    li { 
      border-left: 1px solid transparent;
      display: block;
      margin-top:1px;
      margin-left: -$arrowidth;
      overflow: hidden;
      span {
        padding-left: $arrowidth;
        padding-right: $arrowidth;
        position: relative; 
        >*{
          padding-bottom: .1em;
          padding-top: .1em;
          padding-left: .5em;
          white-space: nowrap;
          text-overflow: ellipsis;
          color: inherit;
          display: inline-block;
          background-color: $arrowcolor;             
        }
        &:after,&:before { 
          content: ""; 
          display: block; 
          width: 0; 
          height: 0;
          border-top: $arrowstrech*$arrowidth solid transparent;
          /* Go big on the size, and let overflow hide */
          border-bottom: $arrowstrech*$arrowidth solid transparent;
          border-left: $arrowidth solid $arrowcolor;
          position: absolute;
          top: 50%;
          margin-top: -$arrowstrech*$arrowidth; 
          z-index: 2;
        }
        &:after{
          right: 0;        
        }
        &:before {
          left: 0;
          border-color: $arrowcolor;
          border-left-color: transparent;
          z-index: 1; 
        }
        &:hover{
          &:before{
            border-color: $arrowcolorhover;  
            border-left-color: transparent;
          }
          &:after{
            border-left-color: $arrowcolorhover;
          }
          a{
            background-color: $arrowcolorhover;  
          }
        } 
      } 
    }
    li:last-child{
      border-top-right-radius: $arrowborderradius;
      border-bottom-right-radius: $arrowborderradius;
      padding-right: 1em
    }
  }
</style>
