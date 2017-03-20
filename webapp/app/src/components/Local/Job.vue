<template>
  <div class="job">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <ul class="breadcrumb">
        <li>
          <span>
            <router-link to="/" class="icon is-small">
              <i class="fa fa-home">Home</i>
            </router-link>
          </span>
        </li>
      </ul>
    </header>
    <h1>Create a Job</h1>
    <section>
      <div>
        <div>Includes:</span>
        <div v-for="d in resources.includes">
          {{d.path}}
        </div>
      </div>
      <div>
        <div>Excludes:</span>
        <div v-for="d in resources.excludes">
          {{d.path}}
        </div>
      </div>
      <div>
        <div>Rules:</div>
        <div v-for="r in rules">
          {{r}}
        </div>
      </div>
    </section>
    <section class="select">
      <span>Backup every </span>
      <input v-model="every" 
        type="number" min="1" step="1" max="120"></input>
      <span v-for="p in periods"
        @click.stop="period=p"
        :class="{selected: p === period}"
        class="period">
        {{p}}
      </span>
    </section>
    <section class="start">
      <span>Start on </span>
      <el-date-picker
        v-model="start"
        type="datetime"
        placeholder="Select date and time">
      </el-date-picker>
    </section>
  </div>
</template>

<script>
  const PATH = require('path')
  function orderNames (a, b) {
    if (a.name > b.name) return -1
    else if (b.name > a.name) return +1
    else return 0
  }
  function order (a, b) {
    if (a.includes === b.includes) return orderNames(a, b)
    else if (a.includes === null) return -1
    else if (b.includes === null) return 1
    else return orderNames(a, b)
  }
  export default {
    name: 'job',
    data () {
      return {
        every: 1,
        periods: ['Min', 'Hour', 'Day', 'Week', 'Month', 'Year'],
        period: 'Day',
        start: ''
      }
    },
    props: [],
    computed: {
      resources () {
        return {
          includes: this.$store.getters.backupIncludes,
          excludes: this.$store.getters.backupExcludes
        }
      },
      rules () {
        let parents = {}
        this.resources.includes.forEach(e => {
          const steps = e.path.split(PATH.sep)
          let acc = ''
          steps.forEach(step => {
            if (step) acc += step + PATH.sep
            else acc = PATH.sep
            parents[acc] = true
          })
        })
        const ancestors = Object.keys(parents).map(e => {
          return {
            name: e,
            includes: null
          }
        })
        const includes = this.resources.includes.map(e => {
          return {
            name: e.path,
            includes: true
          }
        })
        const excludes = this.resources.excludes.map(e => {
          return {
            name: e.path,
            includes: false
          }
        })
        return ancestors.concat(includes, excludes).sort(order)
          .map(e => {
            if (e.includes === false) return '- ' + e.name + '/**'
            else if (e.includes === true) return '+ ' + e.name + '/**'
            else return '+ ' + e.name
          }).concat('- *')
      }
    },
    components: {
    },
    created () {
    },
    watch: {
      start () {
        console.log(this.start)
      }
    },
    methods: {
    }
  }
</script>

<style scoped lang="scss">
  @import "../../breadcrumb.scss";
  @import "../../config.scss";
  .job{
    text-align: left;
    overflow: auto;
    .select {
      display: flex;
      flex-wrap: wrap;
      .period {
        border: 1px solid $bkit-color;
        padding: .25em;
      }      
      .period:last-child {
        border-bottom-right-radius: 5px;      
        border-top-right-radius: 5px;      
      }        
      .period.selected {
        background-color: $bkit-color;
      }
    }
  }
</style>

