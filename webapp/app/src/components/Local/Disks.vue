<template>
  <div class="main local">
    <header class="top">
      <bkitlogo class="logo"></bkitlogo>
      <breadcrumb></breadcrumb>
      <h2>Backup</h2>
    </header>
    <section class="actions">
      <span class="head">Select directories or files to backup</span>
      <span>
        <el-button type="primary"
          class="action"
          @click.stop="backup"
          :disabled="!allowbackup">
          Backup now
        </el-button>
      </span>
      <span class="or">or</span>
      <router-link to="/job">
        <el-button type="primary"
          class="action"
          :disabled="!selected">
          Create a Schedule Task
        </el-button>
      </router-link>
    </section>
    <ul class="disks">
      <li v-if="loading">
          <i class="fa fa-refresh fa-spin fa-fw"></i> Loading...
      </li>
      <disk v-for="d in drives" :name="d"></disk>
    </ul>
    <section v-if="show" class="output">
      <div class="stdout">{{stdout}}</div>
      <div class="stderr">{{stderr}}</div>
    </section>
  </div>
</template>

<script>
  import Breadcrumb from './Breadcrumb'
  import Disk from './Disk'
  const {spawn} = require('child_process')
  const BASH = process.platform === 'win32' ? 'bash.bat' : 'bash'
  const PATH = require('path')

  function order (a, b) {
    return (a > b) ? 1 : ((b > a) ? -1 : 0)
  }
  export default {
    name: 'disks',
    data () {
      return {
        drives: [],
        stderr: '',
        stdout: ''
      }
    },
    computed: {
      selected () {
        return this.includes.length > 0
      },
      includes () {
        return this.$store.getters.backupIncludes || []
      },
      roots () {
        return this.includes.filter(e => e.root === true).map(e => e.path)
      },
      excludes () {
        return this.$store.getters.backupExcludes || []
      },
      filters () {
        const includes = this.includes
          .map(include => {
            return Object.assign(include, {isIncluded: true})
          })
        const excludes = this.excludes
          .map(include => {
            return Object.assign(include, {isIncluded: false})
          })
        return this.makeFilters(includes, excludes)
      },
      show () {
        return this.stdout !== '' || this.stderr !== ''
      },
      allowbackup () {
        return this.roots.length === 1
      }
    },
    components: {
      Disk,
      Breadcrumb
    },
    created () {
      this.refresh()
    },
    methods: {
      refresh () {
        try {
          const fd = spawn(BASH, ['./listDisks.sh'], {cwd: '..'})
          this.$store.dispatch('resetBackupDir')
          let output = ''
          fd.stdout.on('data', (data) => {
            output += `${data}`
          })
          fd.stderr.on('data', (msg) => {
            this.$notify.error({
              title: 'Error',
              message: `${msg}`,
              customClass: 'message error'
            })
          })
          fd.on('close', () => {
            const drives = output.replace(/\n$/, '').split(/\n/)
            this.$nextTick(() => {
              this.drives = drives.sort(order)
              this.loading = false
            })
          })
        } catch (e) {
          this.loading = false
          console.error(e)
        }
      },
      backup () {
        const includes = this.includes.map(e => e.path)
        const filters = this.filters.map(e => {
          return `--filter=${e}`
        })
        const cmd = ['./backup.sh', '--',
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
          code = 0 | code
          if (code === 0) {
            this.$notify.success({
              title: 'Good news',
              message: 'The backkup was successfully done',
              duration: 5000
            })
          } else {
            this.$notify.warning({
              title: 'Please verify logs',
              message: "Something didn't go as expected"
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
  .main.local{
    display: flex;
    flex-direction: column;
    text-align:left;
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
    .actions{
      width: 100%;
      display: flex;
      flex-shrink: 0;
      justify-content:space-between;
      >*{
        margin: 0 .5em;
      }
      .head {
        flex-grow: 1;
      }
      .head, .or {
        padding-top: .5em;
      }
      .action{
        cursor: pointer;
      }
    }
    ul.disks{
      flex-grow:3;
      overflow: auto;
      list-style: none;
      position:relative;
      margin-left: 1em;
    }
    .output{
      flex-grow: 2;
      min-height: 2em;
      overflow: auto;
      font-family: monospace;
      margin-bottom: 1px;
      white-space: pre-line;
      background-color: white;
      color: darkgreen;
      padding: 2px;
      padding-left:1em;
      .stderr {
        color: darkred;
      }
    }
  }
</style>
