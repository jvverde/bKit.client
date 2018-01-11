<template>
  <q-data-table
    :data="data"
    :config="config"
    :columns="columns"
    @refresh="refresh"
  >
    <template slot="col-username" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="col-email" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="col-accessCnt" slot-scope="cell">
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="col-lastAccess" slot-scope="cell">
      <span class="light-paragraph" v-if="cell.data !== null">
        {{ cell.data | moment("from") }}
      </span>
    </template>
    <template slot='col-status' slot-scope='cell'>
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot='col-groups' slot-scope='cell'>
      <span class="light-paragraph">{{cell.data}}</span>
    </template>
    <template slot="selection" slot-scope="selection">
      <q-btn color="primary" @click="editUser(selection)">
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
import {myMixin} from 'src/mixins'

import {
  QCard,
  QCardActions,
  QCardMain,
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
    QCard,
    QCardActions,
    QCardMain,
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
          type: 'date'
        },
        {
          label: 'Status',
          field: 'state',
          width: '10%',
          sort: false,
          format: state => Object.keys(state)
            .map(e => `<i>${e}</i>`).join(', ')
        },
        {
          label: 'Groups',
          field: 'groups',
          width: '10%',
          sort: false,
          type: 'string',
          format: (groups = []) => groups.join(', ')
        }
      ]
    }
  },
  computed: {
    data () {
      return this.users.filter(user => !user.removed).map(user => {
        user.access = user.access || {}
        user.accessCnt = user.access.cnt
        user.lastAccess = new Date(1000 * user.access.lastTime)
        return user
      })
    }
  },
  mixins: [myMixin],
  methods: {
    getDate (value) {
      return value ? new Date(1000 * value) : ''
    },
    getusers () {
      axios.get('/auth/users')
        .then(response => {
          this.users = response.data
          console.log(this.users)
        })
        .catch(this.catch)
    },
    refresh (done) {
      this.getusers()
      done()
    },
    deleteUsers (sel) {
      let remove = {}
      sel.rows.forEach(r => {
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
    },
    editUser (sel) {
      console.log(sel)
      sel.rows.forEach(r => {
        this.$router.push({
          name: 'userview',
          params: {username: r.data.username}
        })
      })
    }
  },
  mounted () {
    this.getusers()
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
