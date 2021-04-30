<template>
  <q-select
    filled
    v-model="value"
    @input="$emit('input', $event)"
    :options="networks"
    option-value="key"
    option-label="description"
    emit-value
    map-options
    label="Network"
    color="teal"
    clearable
    options-selected-class="text-deep-orange"
    >
    <template v-slot:option="scope">
      <q-item
        v-bind="scope.itemProps"
        v-on="scope.itemEvents"
        >
        <q-item-section avatar>
          <q-item-label v-html="scope.opt.key" />
        </q-item-section>
        <q-item-section>
          <q-item-label caption>{{ scope.opt.description }}</q-item-label>
        </q-item-section>
      </q-item>
    </template>
  </q-select>
</template>

<script>
import  { listNetworks }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  mounted: function () {
    $glowdbPromise.then(() => {
      listNetworks().then(l => {
        this.networks = l
        this.value = l[0].key
        this.$emit('input', this.value)
      })
    })
  },
  data () {
    return {
      value: null,
      networks: []
     }
  }
}
</script>
