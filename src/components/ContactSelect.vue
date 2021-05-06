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
    ref="cselect"
    >
    <template v-slot:selected>
      <template v-if="!!value">
      <q-item>
        <q-item-section avatar>
           <q-avatar v-if="value.add">
          <q-icon
            name="add_circle" class="text-green text-h4"/>
          </q-avatar>
          <q-avatar v-else>
            <img :src="value.avatar || avatar(value)">
          </q-avatar>
        </q-item-section>
        <q-item-section>
          <q-item-label v-html="value.name" />
          <q-item-label caption>{{ value.description }}</q-item-label>
        </q-item-section>
      </q-item>
      </template>
      <span v-else> &nbsp;</span>
    </template>

    <template v-slot:option="scope">
      <q-item
        v-bind="scope.itemProps"
        v-on="scope.itemEvents"
        >
        <q-item-section avatar>
          <q-avatar v-if="scope.opt.add">
          <q-icon
            name="add_circle" class="text-green text-h4"/>
          </q-avatar>
          <q-avatar v-else>
            <img :src="scope.opt.avatar || avatar(scope.opt)">
          </q-avatar>
        </q-item-section>
        <q-item-section>
          <q-item-label v-html="scope.opt.name" />
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
    updateAndSelect(c) {
      listContacts().then(l => {
        this.AllContacts = l
        console.log('updating contact select:', c)
        if (!!c) {
          const sel = this.AllContacts.find(con => con.id === c.id)
          console.log('Have New Contact!', sel)
          this.value = sel
        } else {
          this.value = null;
        }
      })
    },
    filterFN(val, update) {
      update(() => {
        const needle = val.toLowerCase()
        this.contacts = this.filter(this.AllContacts).filter(con => {
          if (needle === '') return con;
          const name =  con.name || '';
          const desc = con.description || '';
          const pred = (s) => s !== null && s.toLowerCase().indexOf(needle) > -1;

          return ( pred(name) || pred(desc) )
        })

        this.contacts = [ { name: "Add New Contact",
                            description: "",
                            add: true,
                            avatar: this.avatar()
                          },
                          ...this.contacts
                        ]
      })
    },
    avatar(ct) {
      const self = this;
      function one2six() {
        const n = Math.floor(Math.random() * 10);
        return (n > 0 && n < 7 && n !== self.avatCount) ? n : one2six()
      }
      self.avatCount = one2six()

      return "https://cdn.quasar.dev/img/avatar" + self.avatCount + ".jpg"
    }
  },
  data () {
    return {
      value: null,
      AllContacts: [],
      contacts:[],
      filter: (a) => a,
      avatCount: 1,

     }
  }
}
</script>
