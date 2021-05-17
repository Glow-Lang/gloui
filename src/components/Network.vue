<template>
  <q-select
    filled
    v-model="value"
    @input="emitThings($event)"
    :options="networks"
    emit-value
    map-options
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
          <q-item-label caption>{{ scope.opt.description }}<sup v-if="scope.opt.test"> &nbsp;test</sup></q-item-label>
        </q-item-section>
      </q-item>
    </template>
  <template v-slot:selected>
    <q-item v-if="!!value">
      <q-item-section avatar>
        <q-item-label v-html="value.key" />
      </q-item-section>
      <q-item-section>
        <q-item-label caption>{{ value.description }}<sup v-if="value.test"> &nbsp;test</sup></q-item-label>
      </q-item-section>
    </q-item>
    &nbsp;
  </template>
  </q-select>
</template>

<script>
import  { listNetworks }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  mounted: function () {
    this.reset()
  },
  methods: {
    reset() {
      return $glowdbPromise.then(() => {
        listNetworks().then(l => {
          this.networks = l
          this.value = l[l.length - 1];
          this.$emit('input', "pet")
        })
      })
    },
    emitThings(ev) {
      const emit = ev !== null ? ev.key : null

      console.log('ement', ev)
      this.$emit('select', emit)
      this.$emit('input', emit)
      return ev
    }
  },
  data () {
    return {
      value: null,
      networks: []
     }
  }
}
</script>
