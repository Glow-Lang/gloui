<template>
  <div>
  <q-select
    filled
    v-model="value"
    @input="inputResource"
    :options="resources"
    option-value="id"
    option-label="name"
    emit-value
    map-options
    :label="label"
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
          <q-chip color="teal" text-color="white">
            <q-item-label v-html="scope.opt.name" />
          </q-chip>
        </q-item-section>
        <q-item-section>
          <q-item-label caption>{{ scope.opt.description }}</q-item-label>
          {{ scope.opt.type.name || scope.opt.type }}
        </q-item-section>
      </q-item>
    </template>

    <template v-slot:selected>
      <q-item v-if="value">
        <q-item-section avatar>
          <small>
          <q-chip color="teal" text-color="white">
            <q-item-label v-html="value.name" />
          </q-chip></small>
        </q-item-section>
        <q-item-section>
          <q-item-label caption>{{ value.description }}</q-item-label>
          {{ value.type.name || value.type }}
        </q-item-section>
      </q-item>
      <div v-else> </div>
    </template>
  </q-select>

  <q-dialog v-if="addResource" v-model="addResource" class="full-width">
      <q-layout view="Lhh lpR fff" container class="bg-white">
        <q-header class="bg-primary">
          <q-toolbar>
            <q-toolbar-title>
             Add New Resource
            </q-toolbar-title>
            <q-btn flat v-close-popup  round dense icon="close" />
          </q-toolbar>
        </q-header>

        <q-footer class="bg-black text-white">
          <!-- <q-toolbar inset> -->
          <!--   <q-toolbar-title> -->

          <!--   <q-btn flat v-close-popup :disable="!allowClose" round dense icon="close" /> -->
          <!--    </q-toolbar-title> -->
          <!-- </q-toolbar> -->
        </q-footer>

        <q-page-container>
          <q-page padding>
            <resource :network="network" @cancel="cancel" @input="inputResource"/>

          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>

</div>
</template>

<script>
import  { listResources, listNetworks }  from 'gambit-loader!../../public/glowdb.scm'
import Resource from 'components/Resource.vue'
export default {
  components: { Resource },
  mounted: function () {
    this.updateResources().then(() => {
      if (!this.value) this.value = this.resources[1];
      this.$emit('input', this.value)
    })
  },
  props: ['label', 'network'],
  data () {
    return {
      value: null,
      resources: [],
      addResource: false,
      newResource: {},
     }
  },
  methods: {
    updateResources() {
      this.$forceUpdate()
      console.log('date with net', this.network)
      return listResources().then(l => {
        return listNetworks().then(ns => {
          const nwk = this.network;
          const nw = ns.find(n => n.key === nwk);
          const nat = (nw.test ? 't' : '') + nw.nativeCurrency
          this.resources = [
            {
              name: '[+]',
              type: { name: ' ' },
              description: "Add New Resource",
              add: true
            },
            {
              name: nat,
              type: "Native",
              description: "Crypto for Network: " + nw.key,
              network: nw.key
            },
            ...l.filter(res => res.network === nw.key)]
          this.$emit('input', this.value)
        })
      })
    },
    inputResource(reso) {
      this.addResource = false
      this.value = reso
      const res = this.value
      console.log(res, reso, 'reses')
      if (!!res  && !!res.add) {
        this.addResource = true
      } else {
        this.updateResources();
        this.$forceUpdate();
        this.$emit('input', res)
        this.$emit('select', res)
      }
    },
    cancel() {
      this.addResource = false
      this.value = null
      this.$emit('cancel', null)
      this.$forceUpdate();
    }
  },
}
</script>
