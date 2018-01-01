<template>
  <q-data-table
    :data="users"
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
          width: '60%',
          filter: true,
          sort: true,
          type: 'string'
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
  },
  methods: {
    getusers () {
      axios.get('/auth/users')
        .then(response => {
          // JSON responses are automatically parsed.
          console.log('Users:', response.data)
          this.users = response.data
        })
        .catch(e => {
          this.errors.push(e)
        })
    },
    refresh (done) {
      this.getusers()
      done()
    },
    deleteUsers (users) {
      users.rows.forEach(r => {
        console.log('Row:', r.data.username)
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
