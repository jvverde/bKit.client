<template>
  <q-data-table
    :data="data"
    :config="config"
    :columns="columns"
    @refresh="refresh"
  >
    <!-- Custom renderer for "message" column -->
    <template slot="col-username" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <!-- Custom renderer for "source" column -->
    <template slot="col-email" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="col-accessCnt" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="col-lastAccess" slot-scope="cell">
      <span class="light-paragraph" v-if="cell.data">{{
        getDate(cell.data) | moment("from")
      }}</span>
    </template>
    <!-- Custom renderer for "action" column with button for custom action -->
    <template slot='col-confirmed' slot-scope='cell'>
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <!-- Custom renderer when user selected one or more rows -->
    <template slot="selection" slot-scope="selection">
      <q-btn color="primary" @click="changeMessage(selection)">
        <q-icon name="edit" />
      </q-btn>
      <q-btn color="primary" @click="deleteUsers(selection)">
        <q-icon name="delete" />
      </q-btn>
    </template>
  </q-data-table>
</template>

<script>
import axios from 'axios'
import {
  Toast,
  QDataTable,
  QBtn,
  QIcon,
  QField,
  QInput,
  QList,
  QListHeader,
  QItem,
  QItemMain,
  QItemTile,
  QItemSide,
  QSideLink
} from 'quasar'

export default {
  name: 'form',
  components: {
    Toast,
    QDataTable,
    QBtn,
    QIcon,
    QField,
    QInput,
    QList,
    QListHeader,
    QItem,
    QItemMain,
    QItemTile,
    QItemSide,
    QSideLink
  },
  data () {
    return {
      users: [],
      config: {
        title: 'Users on system',
        refresh: true,
        noHeader: false,
        // columnPicker: true,
        // leftStickyColumns: 0,
        // rightStickyColumns: 2,
        bodyStyle: {
          maxHeight: '500px'
        },
        rowHeight: '50px',
        responsive: true,
        pagination: {
          rowsPerPage: 15,
          options: [5, 10, 15, 30, 50, 500]
        },
        selection: 'multiple'
      },
      columns: [
        {
          label: 'Username',
          field: 'username',
          width: '30%',
          filter: true,
          sort: true,
          type: 'string'
        },
        {
          label: 'Email',
          field: 'email',
          width: '45%',
          filter: true,
          sort: true,
          type: 'string'
        },
        {
          label: 'Access Cnt',
          field: 'accessCnt',
          width: '15%',
          filter: true,
          sort: true,
          type: 'number'
        },
        {
          label: 'Last Access',
          field: 'lastAccess',
          width: '15%',
          sort: true,
          type: 'number'
        },
        {
          label: 'Confirmed',
          field: 'confirmed',
          width: '10%',
          sort: true,
          type: 'number'
        }
      ]
    }
  },
  computed: {
    data () {
      return this.users.filter(user => !user.removed)
    }
  },
  methods: {
    getDate (value) {
      return value ? new Date(1000 * value) : ''
    },
    getusers () {
      axios.get('/auth/users')
        .then(response => {
          // JSON responses are automatically parsed.
          console.log('Users:', response.data)
          this.users = response.data
        })
        .catch(e => {
          const msg = e.response.data.msg
          Toast.create.negative({
            html: msg,
            timeout: 10000
          })
        })
    },
    refresh (done) {
      this.getusers()
      done()
    },
    deleteUsers (users) {
      let remove = {}
      users.rows.forEach(r => {
        remove[r.data.username] = r
        //  this.table.splice(row.index, 1)
        axios.delete(`/auth/user/${encodeURIComponent(r.data.username)}`)
          .then(response => {
            this.$set(
              this.users[remove[response.data.user].index], 'removed', true
            )
          })
          .catch(e => {
            let msg = e.toString()
            if (e.response instanceof Object &&
              e.response.data instanceof Object) {
              msg = `<small>${msg}</small><br/><i>${e.response.data.msg}</i>`
            }
            Toast.create.negative({
              html: msg,
              timeout: 10000
            })
          })
      })
    }
  },
  mounted () {
    this.getusers()
  },
  beforeDestroy () {
    this.ws = undefined
  }
}
</script>

<style lang="stylus">
</style>
