<template>
  <q-select
    filled
    v-model="value"
    @input="$emit('input', $event)"
    :options="assets"
    use-input
    emit-value
    map-options
    :label="label"
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
        <span v-if="!ownerID"> Owner: {{ scope.opt.owner.name }} </span>
        <br/>

          <resource-item v-model="scope.opt.resource" class="text-center"/>
      </q-item>
    </template>
    <template v-slot:selected>
      <resource-item v-if="value" :value="value.resource" />
      &nbsp;
      <!-- {{ ownerID }} -->
    </template>
  </q-select>


</template>

<script>
import  { listAssetEntities }  from 'gambit-loader!../../public/glowdb.scm'
import ResourceItem from 'components/ResourceItem.vue'
export default {
  components: { ResourceItem },
  props: {
    filterFn: {  default: (a) => a, type: Function },
    ownerID: { default: null },
    label: { default: "Asset", type: String }
  },
  created: function () {
      listAssetEntities().then(l => {
        this.AllAssets = l
      })
  },

  methods: {
    filterFN(val, update) {
      update(() => {
        const needle = val.toLowerCase()
        const fn = (typeof this.filterFn === 'function') ? this.filterFn : (a) => a;
        this.assets = fn(this.AllAssets).filter(ass => {
          if (!!this.ownerID) return this.ownerID === ass.owner.id;
          if (needle === '') return ass;
          const name =  ass.resource.name;
          const desc = ass.resource.description;
          const pred = (s) => s !== null && s.toLowerCase().indexOf(needle) > -1;

          return ( pred(name) || pred(desc) )
        })
      })
    }
  },
  data () {
    return {
      value: null,
      AllAssets: [],
      assets: null,

     }
  }
}
</script>
