<template>
  <div class="job">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <breadcrumb></breadcrumb>
      <h2>Create a Job</h2>
    </header>
    <div class="alert" v-if="includes.length === 0">
      No directories or files has been selected
    </div>
    <div class="resources" v-if="includes.length > 0">
      <div v-if="includes.length > 0 " class="head">Backup</div>
      <div class="includes list">
        <span v-for="f in includes">
          {{f.path}}
          <i class="fa fa-times-circle" aria="hidden" @click="remove(f)"></i>
        </span>
      </div>
      <div v-if="excludes.length > 0 "  class="head">Excluding</div>
      <div class="excludes list">
        <span v-for="f in excludes">
          {{f.path}}
          <i class="fa fa-times-circle" aria="hidden" @click="remove(f)"></i>
        </span>
      </div>
      <div v-if="excludeRules.length > 0 " class="head">Exclude Rules</div>
      <div class="rules list">
        <span v-for="r in excludeRules">
          {{r}}
          <i class="fa fa-times-circle" aria="hidden" @click="removeRule(r)"></i>
        </span>
      </div>
      <div class="addrules">
        <label>Add an Exclude Rule:</label>
        <input v-model="newExcludeRule" @keyup.enter="addExcludeRule" type="text"></input>
        <i v-show="newExcludeRule !== null"
          class="fa fa-check-circle-o enter" aria="hidden" @click="addExcludeRule">
        </i>
      </div>
    </div>
    <div class="task" v-if="includes.length > 0">
      <section class="select">
        <span>Task Name</span>
        <input v-model="taskname" type="text" class="name"></input>
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
          class="picker"
          v-model="start"
          type="datetime"
          placeholder="Select date and time">
        </el-date-picker>
      </section>
      <section class="action">
        <el-button type="primary" @click.stop="create"
          v-show="wait === false"
          :disabled="taskname === ''">
          Create Task
          <i class="el-icon-arrow-right el-icon-right"></i>
        </el-button>
        <div v-show="wait === true">
          <i class="fa fa-cog fa-spin fa-2x fa-fw"></i>
          <span>Creating task...</span>
        </div>
      </section>
    </div>
    <section v-if="show" class="output">
      <div class="stdout">{{stdout}}</div>
      <div class="stderr">{{stderr}}</div>
    </section>
  </div>
</template>

<script>
  import Breadcrumb from './Breadcrumb'

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
        newExcludeRule: null,
        excludeRules: [],
        taskname: '',
        wait: false,
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
        start: 600000 + Date.now(),
        stdout: '',
        stderr: ''
      }
    },
    props: [],
    computed: {
      includes () {
        return this.$store.getters.backupIncludes
      },
      excludes () {
        return this.$store.getters.backupExcludes
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
      },
      show () {
        return this.stdout !== '' || this.stderr !== ''
      }
    },
    components: {
      Breadcrumb
    },
    created () {
    },
    watch: {
      start () {
        console.log(this.start)
      }
    },
    methods: {
      addExcludeRule () {
        this.excludeRules.push(this.newExcludeRule)
        this.newExcludeRule = null
      },
      removeRule (r) {
        const index = this.excludeRules.indexOf(r)
        if (index !== -1) this.excludeRules.splice(index, 1)
      },
      remove (entry) {
        this.$store.dispatch('rmBackupDir', entry)
      },
      create () {
        const start = new Date(this.start || 3600000 + Date.now())
        const options = [
          '--name', this.taskname,
          `-${this.period}`, this.every,
          '--install',
          '--start', start.toISOString()
        ]
        const includes = this.includes.map(e => e.path)
        const filters = this.filters.map(e => {
          return `--filter=${e}`
        })
        const excludesrules = this.excludeRules.map(r => {
          return `--filter=- ${r}`
        })
        const cmd = ['./ctask.sh',
          ...options,
          ...excludesrules,
          ...filters,
          ...includes
        ]
        const fd = spawn(BASH, cmd, {cwd: '..'})

        fd.stdout.on('data', (data) => {
          this.stdout += data
        })

        fd.stderr.on('data', (data) => {
          this.stderr += data
        })

        fd.on('close', (code) => {
          this.wait = false
          code = 0 | code
          if (code === 0) {
            this.$notify.success({
              title: 'Good news',
              message: 'Task was successfully created',
              duration: 5000
            })
          } else {
            this.$notify.warning({
              title: 'Please verify logs',
              message: "Something didn't go as expected"
            })
          }
        })
        this.wait = true
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
        const join = (...a) => {
          if (a[0].match(/\\|\/|[a-zA-Z]:/)) {
            return PATH.join(...a)
          } else {
            return PATH.join(PATH.sep, ...a)
          }
        }
        return ancestors.concat(includes, excludes).sort(order)
          .map(e => {
            const is = condition => e.isIncluded === condition
            if (is(false) && e.dir) return '-/ ' + join(e.path, '/*')
            else if (is(false) && e.file) return '-/ ' + join(e.path)
            else if (is(true) && e.dir) return '+/ ' + join(e.path, '/')
            else if (is(true) && e.file) return '+/ ' + join(e.path)
            else return '+/ ' + join(e.path)
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
    overflow: hidden;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    header.top{
      flex-shrink: 0;
      .logo{
        float:left;
      }
      h2{
        width: 100%;
        text-align: center;
      }
    }
    .alert{
      flex-grow: 4;
      align-self: center;
    }
    .task{
      flex-grow: 2;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      border-top:1px solid black;
      padding-top:5px;
      margin-top: 1px;
      section:not(.action) {
        width: 80%;
        margin: .5em;
        :first-child{
          width:30%;
          display: inline-block;
          text-align: right;
          margin-right: .5em;
        }
        >*{
          padding: .5em;
        }
        .picker{
          margin-left: -.3em;
          padding-left: 0em;
        }
      }
      section.select {
        display: flex;
        flex-wrap: wrap;
        input{
          border: 1px solid $bkit-color;
          text-align: right;
          background-color: $bkit-color;
          border-bottom-left-radius: 5px;
          border-top-left-radius: 5px;
          &:hover{
            background-color: bisque;
          }
        }
        .period {
          border: 1px solid $bkit-color;
          border-left-width: 0;
          cursor: pointer;
        }
        .period:last-child {
          border-bottom-right-radius: 5px;
          border-top-right-radius: 5px;
        }
        .period.selected {
          background-color: $bkit-color;
        }
        .name {
          border-radius: 5px;
          text-align: left;
          background-color: beige;
        }
      }
      section.action{
        width: 65%;
        >*{
          float: right;
        }
      }
    }
    .resources{
      padding: .5em;
      flex-grow: 1;
      display: flex;
      flex-direction: column;
      :not(.head) + div.list{
        display: none;
      }
      div.list{
        margin-left: 1em;
        margin-bottom: 5px;
        min-height: 2.5em;
        overflow-y: auto;
        background-color:gainsboro;
        padding: 5px;
        color: forestgreen;
        border-radius:5px;
        span{
          display: inline-block;
          margin: 3px;
          min-width: 3em;
          padding: 3px;
          background-color:oldlace;
          border-radius:5px;

          i{
            float: right;
            display: inline-block;
            margin-left: 5px;
            visibility: hidden;
          }
          &:hover {
            background-color:darkgrey;
            color: white;
            i{
              visibility: visible;
            }
            i:hover{
              color:darkred;
            }
          }
        }
      }
      .addrules{
        border-top:1px solid black;
        padding-top:.5em;
        margin-top: 1px;
        display: flex;
        align-items: center;
        >*{
          display: inline-block;
        }
        >*:not(first-child){
          margin-left: 5px;
        }
        input{
          border: 1px solid $bkit-color;
          border-radius: 5px;
          background-color: beige;
          padding: .5em;
          &:hover{
            background-color: bisque;
          }
        }
        .enter{
          font-size: 125%;
        }
        .enter:hover {
          cursor: pointer;
          color: darkgreen;
        }
      }
    }
  }
</style>

