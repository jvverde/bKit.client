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
        <div>Includes:</div>
        <div v-for="d in includes">
          {{d.path}}
        </div>
      </div>
      <div>
        <div>Excludes:</div>
        <div v-for="d in excludes">
          {{d.path}}
        </div>
      </div>
      <div>
        <div>Rules:</div>
        <div v-for="r in roots">
          {{r.name}}: {{r.values}}
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
        periods: ['Min', 'Hour', 'Day', 'Week', 'Month', 'Year'],
        period: 'Day',
        start: '',
        includes: [],
        excludes: []
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
      roots () {
        let includesOf = {}
        let excludesOf = {}
        this.includes.forEach(e => {
          includesOf[e.root] = includesOf[e.root] || []
          includesOf[e.root].push(e)
        })
        this.excludes.forEach(e => {
          excludesOf[e.root] = excludesOf[e.root] || []
          excludesOf[e.root].push(e)
        })
        return Object.keys(includesOf).map(root => {
          return {
            name: root,
            values: this.order(includesOf[root], excludesOf[root] || [])
          }
        })
      }
    },
    components: {
    },
    created () {
      this.refresh()
    },
    watch: {
      start () {
        console.log(this.start)
      },
      resources () {
        this.refresh()
      }
    },
    methods: {
      order (includes, excludes) {
        let parents = {}
        includes.forEach(e => {
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
            path: e,
            isIncluded: null
          }
        })
        const join = (...a) => PATH.join(PATH.sep, ...a)
        return ancestors.concat(includes, excludes).sort(order)
          .map(e => {
            const is = condition => e.isIncluded === condition
            if (is(false) && e.dir) return '- ' + join(e.path, '***')
            else if (is(false) && e.file) return '- ' + join(e.path)
            else if (is(true) && e.dir) return '+ ' + join(e.path, '**')
            else if (is(true) && e.file) return '+ ' + join(e.path)
            else return '+ ' + join(e.path)
          }).concat('- *')
      },
      update () {
        this.refresh()
      },
      translate (list, cb) {
        if (list.length === 0) return undefined
        try {
          const paths = list.map(e => e.path)
          const fd = spawn(BASH, ['./getRoot.sh', ...paths], {cwd: '..'})
          let output = ''
          fd.stdout.on('data', (data) => {
            output += `${data}`
          })
          fd.stderr.on('data', (msg) => {
            console.error(`${msg}`)
            this.$notify.error({
              title: 'Error',
              message: `${msg}`,
              customClass: 'message error'
            })
          })
          fd.on('close', () => {
            const entries = output.replace(/\n$/, '').split(/\n/)
            const pathsAndRoots = entries.map(entry => {
              const [orig, path, root] = entry.split('|')
              return Object.assign({}, list.find(e => e.path === orig), {
                path: path.replace(root, ''),
                root: root
              })
            })
            this.$nextTick(() => {
              cb(pathsAndRoots)
            })
          })
        } catch (e) {
          console.error(e)
        }
      },
      refresh () {
        this.translate(this.resources.includes, includes => {
          this.includes = includes.map(include => {
            return Object.assign(include, {isIncluded: true})
          })
        })
        this.translate(this.resources.excludes, excludes => {
          this.excludes = excludes.map(exclude => {
            return Object.assign(exclude, {isIncluded: false})
          })
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

