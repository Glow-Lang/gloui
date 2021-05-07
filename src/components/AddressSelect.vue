<template>
  <div>
  <q-select v-if="!addNewAddress"
    filled
    v-model="value"
    @input="addressInput()"
    :options="addresses"
    option-label="number"
    use-input
    multiple
    emit-value
    map-options
    label="Address(es)"
    color="teal"
    ref="addressSelect"
    options-selected-class="text-deep-orange"
    @filter="filterFN"
    >
    <template v-slot:selected>
      <template v-if="value && value[0]">
      <q-item>
        <q-item-section>
          <q-item-label v-html="displayValues()" ></q-item-label>
          <small> {{ value.length }} address<template v-if="value.length > 1">es </template></small>
            </q-item-section>
      </q-item>
      </template>
      <span v-else> &nbsp;</span>
    </template>
    <template v-slot:option="{ itemProps, itemEvents, opt, selected, toggleOption }">
          <q-item
            v-bind="itemProps"
            v-on="itemEvents"
          >
        <q-item-section top side v-if="opt.secret">
          <q-icon name="enhanced_encryption" />
        </q-item-section>
            <q-item-section>
              <q-item-label v-html="opt.label" ></q-item-label>
              <small> {{ opt.number }} </small>
            </q-item-section>
            <q-item-section side>
              <q-toggle v-if="!opt.add" :value="selected" @input="toggleOption(opt)" />
              <q-avatar v-else>
              <q-icon
                name="add_circle" class="text-green text-h4"/>
              </q-avatar>
            </q-item-section>
          </q-item>
    </template>

        <!-- {{ value }} 123 -->
    <!-- {{ (AllAddresses && AllAddresses[0]) }} -->
  </q-select>
  <et-address v-else v-model="newAddress"
              @cancel="addNewAddress = !addNewAddress"
              @input="saveNewAddress($event)"/>
</div>
</template>

<script>
import  { listAddresses, saveAddress }  from 'gambit-loader!../../public/glowdb.scm'
import EtAddress from 'components/Address.vue'

export default {
  props: { mustHaveSecret: { type: Boolean, default: false },
           selected: { type: Array,
                       default: () => []
                     }
         },
  components: { EtAddress },
  beforeMount: function () {
      listAddresses().then(l => {
        this.AllAddresses = l
        console.log('Alladdreeses', l, this.selected)
       this.$forceUpdate()
      })
  },
  mounted() {
    console.log('mounted', this.selected, this.value)
 },
  beforeUpdate() {
    console.log('Repfore Update', this.selected, this.value)
    if ((!this.value || !this.value[0]) && !!this.selected)  {
      const sel = this.selected.map(a => this.AllAddresses.find(aa => aa.id === a.id))
      this.value = sel
    }
    console.log('Update wiyj', this.value)
  },
  methods: {
    displayValues() {
      if (!!this.value && !!this.value[0])
        return this.value.map(a => a.label).join(', ');
    },
    addressInput() {

      const ads = this.value
      if (ads.length > 0 && ads[ads.length - 1].add) {
        ads.length = ads.length - 1;
        this.addNewAddress = true
      }
      this.$emit('input', ads)

    },
    saveNewAddress(add) {
      add.id = randomUUID();

      return saveAddress(add).then(() => {
        listAddresses().then(l => {
          this.AllAddresses = l
          console.log('New address added', l, this.selected)
          this.$forceUpdate()
        })
      })
    },

    updateSelected() {
      // const sel = this.selected.map(a => this.AllAddresses.find(aa => aa.id === a.id))
      // console.log('mosy have secret', this.mustHaveSecret, sel, this.value)

      // const newSel = (!!this.value) ? sel.filter(s => !this.value.includes(s)) : sel;
      //   console.log('selected', newSel)
      // newSel.map(s => this.$refs.addressSelect.add(s))
    },
    filterFN(val, update) {
      update(() => {
        const needle = val.toLowerCase()
        // this.addresses = this.filter(this.AllAddresses).filter(con => {
        //   if (needle === '') return con;
        //   const name =  con.name;
        //   const desc = con.description;
        //   const pred = (s) => s !== null && s.toLowerCase().indexOf(needle) > -1;

        //   return ( pred(name) || pred(desc) )
        this.addresses = this.filter(this.AllAddresses);
        console.log("filter", this.value, this.selected)


        console.log('Secret myst?', this.mustHaveSecret)
        if (this.mustHaveSecret) {
          this.addresses = this.addresses.filter(a => typeof a.secret === 'string')
        }

        // if (this.ownerID) {
        //   this.addresses = this.addresses.filter(a => typeof a.secret === 'string')
        // }
        this.addresses = [ { label: "Create New Address",
                             number: "Add a new Address for this Contact",
                             add: true
                           }, ...this.addresses ]

      return true;
      })
    }
  },
  // watch: {
  //   selected(nw, old) {
  //     if (!this.inited) {
  //       console.log('initing selected')
  //       this.inited = true
  //       this.updateSelected()
  //     }
  //     console.log('After Update selected', nw, old, nw === old)
  //   }},
  data () {
    return {
      inited: false,
      value: null,
      AllAddresses: [],
      addresses:[],
      filter: (a) => a,
      addNewAddress: false,
      newAddress: {}

     }
  }
}
</script>
