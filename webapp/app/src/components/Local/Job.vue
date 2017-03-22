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
    <div @click.stop="update">Update...</div>
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
          if (!e.dir) steps.pop() // discard file name if it is a file
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
            dir: e.dir,
            includes: true
          }
        })
        const excludes = this.resources.excludes.map(e => {
          return {
            name: e.path,
            dir: e.dir,
            includes: false
          }
        })
        return ancestors.concat(includes, excludes).sort(order)
          .map(e => {
            if (e.includes === false && e.dir) return '- ' + PATH.join(e.name, '***')
            else if (e.includes === false && !e.dir) return '- ' + e.name
            else if (e.includes === true && e.dir) return '+ ' + PATH.join(e.name, '**')
            else if (e.includes === true && !e.dir) return '+ ' + e.name
            else return '+ ' + e.name
          }).concat('- *')
      },
      roots () {
        let roots = {}
        this.resources.includes.forEach(e => {
          if (e.root) roots[e.path] = true
        })
        console.log(roots)
        return Object.keys(roots)
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
      rulesOfRoot (root) {
        return this.rules.filter(rule => rule.startsWith(root, 2))
      },
      update () {
        console.log('Roots:', this.roots)
        this.roots.forEach(root => {
          const rules = this.rulesOfRoot(root)
          console.log(rules)
        })
      }
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

