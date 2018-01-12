<template>

  <table class="column absolute-center" responsive striped>
    <tbody>
      <tr>
        <td>Name</td>
        <td>Users</td>
      </tr>
      <tr v-for="(group, index) in groups">
        <td data-th="Name">
          <q-input type="text" v-model="group.name" :readonly="!group.new" @focus="show"/>
        </td>
        <td data-th="Users">
          <q-chips-input v-model="group.users"/>
        </td>
      </tr>
    </tbody>
    <tfoot>
      <tr>
        <th colspan="2">
          <q-btn icon="add" color="primary" @click="add">Add</q-btn>
        </th>
      </tr>
    </tfoot>
  </table>

</template>

<script>
import axios from 'axios'
import {myMixin} from 'src/mixins'

import {
  QChipsInput,
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
} from 'quasar'

export default {
  name: 'form',
  components: {
    QChipsInput,
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
      groups: []
    }
  },
  computed: {
  },
  mixins: [myMixin],
  methods: {
    getgroups () {
      axios.get('/auth/groups')
        .then(response => {
          this.groups = response.data
          console.log(this.groups)
        })
        .catch(this.catch)
    },
    add () {
      this.groups.push({
        name: '',
        new: true,
        users: []
      })
    },
    show (e) {
      console.log(e)
    }
  },
  mounted () {
    this.getgroups()
  },
  beforeDestroy () {
  }
}
</script>

<style lang="stylus">
</style>
