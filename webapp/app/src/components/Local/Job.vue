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
        <div>Filters:</div>
        <div v-for="f in filters">
          {{f}}
        </div>
      </div>
    </section>
    <section class="select">
      <span>Backup every </span>
      <input v-model="every"
        type="number" min="1" step="1" max="120"></input>
      <span v-for="(val,key) in periods"
        @click.stop="period=key"
        :class="{selected: key === period}"
        class="period">
        {{val}}
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
    <div @click.stop="create">Create a Job</div>
  </div>
</template>

<script>
  const {spawn} = require('child_process')
  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
  const PATH = require('path')

  function orderNames (a, b) {
    if (a.path > b.path) return -1
    else if (b.path > a.path) return +1
    else return 0
  }
  function order (a, b) {
    if (a.isIncluded === b.isIncluded) return orderNames(a, b)
    else if (a.isIncluded === null) return -1
    else if (b.isIncluded === null) return 1
    else return orderNames(a, b)
  }
  export default {
    name: 'job',
    data () {
      return {
        every: 1,
        periods: {
          m: 'Min',
          h: 'Hour',
          d: 'Day',
          w: 'Week',
          M: 'Month',
          y: 'Year'
        },
        period: 'd',
        start: ''
      }
    },
    props: [],
    computed: {
      includes () {
        return this.$store.getters.backupIncludes
      },
      filters () {
        const includes = (this.$store.getters.backupIncludes || [])
          .map(include => {
            return Object.assign(include, {isIncluded: true})
          })
        const excludes = (this.$store.getters.backupExcludes || [])
          .map(include => {
            return Object.assign(include, {isIncluded: false})
          })
        return this.makeFilters(includes, excludes)
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
      create () {
        const options = ['--name', 'teste', `-${this.period}`, this.every]
        if (this.start) options.push('--start', this.start)
        const includes = this.includes.map(e => e.path)
        const filters = this.filters.map(e => {
          return `--filter=${e}`
        })
        const cmd = ['./ctask.sh', '--test',
          ...options,
          ...filters,
          ...includes
        ]
        console.log(cmd)
        const fd = spawn(BASH, cmd, {cwd: '..'})

        fd.stdout.on('data', (data) => {
          console.log('' + data)
          console.log('stdout', `${data}`)
        })

        fd.stderr.on('data', (data) => {
          this.$notify.error({
            title: 'Create Job',
            message: `Error:${data}`
          })
        })

        fd.on('close', (code) => {
          code = 0 | code
          if (code === 0) {
            this.$notify.success({
              title: 'Good news',
              message: 'Job was successfully created'
            })
          }
        })
      },
      makeFilters (includes, excludes) {
        let parents = {}
        includes.forEach(e => {
          const steps = e.path.split(PATH.sep)
          steps.pop() // discard entry name. Only use ancestors
          let acc = ''
          steps.forEach(step => {
            if (step) acc += step + PATH.sep
            else acc = PATH.sep
            parents[acc] = true
          })
        })
        const ancestors = Object.keys(parents).map(e => {
          return {
            path: e,
            isIncluded: null
          }
        })
        const join = (...a) => PATH.join(PATH.sep, ...a)
        return ancestors.concat(includes, excludes).sort(order)
          .map(e => {
            const is = condition => e.isIncluded === condition
            if (is(false) && e.dir) return '- ' + join(e.path, '/*')
            else if (is(false) && e.file) return '- ' + join(e.path)
            else if (is(true) && e.dir) return '+ ' + join(e.path, '/')
            else if (is(true) && e.file) return '+ ' + join(e.path)
            else return '+ ' + join(e.path)
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
    .rules{
      div{
        margin-left: 1em;
      }
    }
  }
</style>

