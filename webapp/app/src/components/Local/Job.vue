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
          {{d}}
        </div>
      </div>
      <div>
        <div>Excludes:</span>
        <div v-for="d in resources.excludes">
          {{d}}
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
  const path = require('path')
  function order (a, b) {
    return (a > b) ? 1 : ((b > a) ? -1 : 0)
  }
  function rules (list = [], ast) {
    const result = {}
    list.forEach((e = '') => {
      console.log('sep=', path.sep)
      const steps = e.split(path.sep)
      let rpath = ''
      steps.forEach(step => {
        console.log(step)
        rpath += step + '/'
        result[rpath] = true
      })
      result[e + '/' + ast] = true
    })
    return result
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
        const includes = rules(this.resources.includes, '**')
        return Object.keys(includes).map(e => '+ ' + e).sort(order)
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

