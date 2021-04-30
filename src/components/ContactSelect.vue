<template>
  <q-select
    filled
    v-model="value"
    @input="$emit('input', $event)"
    :options="contacts"
    option-label="name"
    use-input
    emit-value
    map-options
    label="Contact"
    color="teal"
    clearable
    options-selected-class="text-deep-orange"
    @filter="filterFN"
    >
    <template v-slot:option="scope">
      <q-item
        v-bind="scope.itemProps"
        v-on="scope.itemEvents"
        >
        <q-item-section avatar>
          <q-item-label v-html="scope.opt.name" />
        </q-item-section>
        <q-item-section>
          <q-item-label caption>{{ scope.opt.description }}</q-item-label>
        </q-item-section>
      </q-item>
    </template>
        <!-- {{ value }} 123 -->
    <!-- {{ (AllContacts && AllContacts[0]) }} -->
  </q-select>


</template>

<script>
import  { listContacts }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  mounted: function () {
      listContacts().then(l => {
        this.AllContacts = l
      })
  },
  methods: {
    filterFN(val, update) {
      update(() => {
        const needle = val.toLowerCase()
        this.contacts = this.filter(this.AllContacts).filter(con => {
          if (needle === '') return con;
          const name =  con.name;
          const desc = con.description;
          const pred = (s) => s !== null && s.toLowerCase().indexOf(needle) > -1;

          return ( pred(name) || pred(desc) )
        })
      })
    }
  },
  data () {
    return {
      value: null,
      AllContacts: [],
      contacts:[],
      filter: (a) => a,

     }
  }
}
</script>
