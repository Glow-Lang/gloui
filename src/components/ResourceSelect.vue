<template>
  <q-select
    filled
    v-model="value"
    @input="$emit('input', $event)"
    :options="resources"
    option-value="id"
    option-label="name"
    emit-value
    map-options
    label="Resource"
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
          <q-item-label v-html="scope.opt.name" />
        </q-item-section>
        <q-item-section>
          <q-item-label caption>{{ scope.opt.description }}</q-item-label>
          {{ scope.opt.type.name }} {{ scope.opt.path }}
        </q-item-section>
      </q-item>
    </template>
  </q-select>
</template>

<script>
import  { listResources }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  mounted: function () {
      listResources().then(l => {
        this.resources = l
      })
  },
  data () {
    return {
      value: null,
      resources: []
     }
  }
}
</script>
