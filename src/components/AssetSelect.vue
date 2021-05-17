<template>
<q-select
  style="height:100%"
  filled
  v-model="value"
  @input="$emit('input', $event)"
  :options="assets"
  use-input
  emit-value
  map-options
  :label="label"
  color="teal"
  options-selected-class="text-deep-orange"
  @filter="filterFN"
  ref="assSel"
    >
    <template v-slot:option="scope">
      <q-item
        style="height:100%"
        v-bind="scope.itemProps"
        v-on="scope.itemEvents"
        >
        <q-item-section top side class="justify-center">
          <q-avatar v-if="scope.opt.edit">
            <q-icon name="add_circle" class="text-green text-h4"/>
          </q-avatar>
          <q-avatar v-else>
          <jazzicon :address="scope.opt.address.number" :diameter="20" />
          <q-icon v-if="scope.opt.address.secret" name="enhanced_encryption" />
          </q-avatar>

        </q-item-section>
        <span v-if="!ownerID"> Owner: {{ scope.opt.owner.name }} </span>
        <q-item-section>
          {{ scope.opt.address.label}}
        <q-item-label>
          <small class="text-grey text-bold">{{ scope.opt.address.number }}</small>
        </q-item-label>

       </q-item-section>
      </q-item>
    </template>

    <template v-slot:selected>
      <q-item v-if="value"

              style="height:100%"
              >
        <q-item-section top side class="justify-center">
          <jazzicon :address="value.address.number" :diameter="20" />
          <q-icon  v-if="value.address.secret" name="enhanced_encryption" />
        </q-item-section>
         <span v-if="!ownerID"> Owner: {{ value.owner.name }} </span>
        <q-item-section top >
          {{ value.address.label}}
          <br/>
        <q-item-label >
          <small class="text-grey text-bold">{{ value.address.number }}</small>
        </q-item-label>
        <div v-if="balance === 'ask'">
          <q-spinner-orbit
            color="primary"
            size="2em"
            />
          <q-tooltip :offset="[0, 8]">Asking network for Balance</q-tooltip>
        </div>

        <div class="text-h5 secondary" v-else-if="balance">
          Balance: {{ value.balance.resource.name }} {{ value.balance.balance }}
        </div>

        </q-item-section>
       </q-item>
      <!-- {{ value  }} -->
      <!-- id: {{ ownerID }} -->
      &nbsp;
       <!-- {{ AllAssets }} -->
    </template>
  </q-select>


</template>

<script>
import  { listAssetEntities }  from 'gambit-loader!../../public/glowdb.scm'
// import ResourceItem from 'components/ResourceItem.vue'
import Jazzicon from 'vue-jazzicon';


export default {
  components: { Jazzicon },
  props: {
    filterFn: {  default: (a) => a, type: Function },
    ownerID: { default: null },
    mustHaveSecret: { default: false, type: Boolean },
    label: { default: "Asset", type: String }
  },
  created: function () {
    this.updateAssets()
  },
  mounted: function () {
    this.updateAssets().then(a => {
      this.filterFN('', fn => fn())
      if (!this.value) {
        this.value = this.assets[1]
        this.$emit('input', this.value)
      } else { console.log('Sane Asser', this.value) }
    })
  },

  methods: {
    updateAssets() {
      return listAssetEntities().then(l => {
        this.AllAssets = l
      })
    },
    add(item) {
      this.$refs.assSel.add(item)
    },
    cancel() {
      this.value = null;
      this.updateAssets().then(a => {
        this.filterFN('', fn => fn())
        if (!this.value) {
          if (!!this.assets[1]) {
            this.value = this.assets[1]
          } else if (!!this.ownerID) {
            this.value = this.assets[0]
          }
          this.$emit('input', this.value)
        } else { console.log('Sane Asser', this.value) }
      })
    },
    filterFN(val, update) {
      update(() => {
        const needle = val.toLowerCase()
        const fn = (typeof this.filterFn === 'function') ? this.filterFn : (a) => a;
        this.assets = this.AllAssets
        console.log("Assets:", this.assets, 'ownerID', this.ownerID)

        if (this.mustHaveSecret) {
          this.assets = this.assets.filter(a => typeof a.address.secret === 'string')
        }


        this.assets = this.assets.sort ((a, b) => a.address.label < b.address.label);

        this.assets = [ { owner: { id: this.ownerID },
                          address: { label: "Add an Address",
                                     number: "Edit the contact to add an address" },
                          edit: true
                        }, ...this.assets ]

        if (!!this.ownerID) {
          this.assets = this.assets.filter(a => a.owner.id === this.ownerID)
        } else {
          this.assets = []
          this.value = null
        }

        if (!!this.value && this.value.owner.id !== this.ownerID) {
          this.value = null
        }
        return true;
        // this.assets = fn(this.AllAssets).filter(ass => {
      //     if (!!this.ownerID) return this.ownerID === ass.owner.id;
      //     if (needle === '') return ass;
      //     const name =  ass.resource.name;
      //     const desc = ass.resource.description;
      //     const pred = (s) => s !== null && s.toLowerCase().indexOf(needle) > -1;

      //     return ( pred(name) || pred(desc) )
      //   })
       })
    }
  },
  data () {
    return {
      value: null,
      AllAssets: [],
      assets: null,
      balance: null
     }
  }
}
</script>
