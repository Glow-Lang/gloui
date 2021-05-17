<template>
<div>
  <div class="row">
    <div class="col">
      Network <q-chip> {{ network }} </q-chip>
    </div>
  </div>
   <div class="col">
      <q-input v-model="value.name" label="Name (unique, used as the key)"
               v-on:input="inputResourceEvent"/>
      <q-input v-model="value.description" label="Optional: Description"
               v-on:input="inputResourceEvent"/>
      <q-input v-model="value.exchangeCurrency" label="Optional: The crypoCurrency to calculate exchange rates"
               v-on:input="inputResourceEvent"/>
      <!-- <network :value="network" @input="network = $event" /> -->
    </div>
  <div class="row">
    <div class="col full-width">
      Type
      <q-select
        filled
        v-model="value.type"
        :options="types"
        option-label="name"
        emit-value
        map-options
        label="Type"
        color="teal"
        clearable
        options-selected-class="text-deep-orange"
        v-on:input="inputResourceEvent"
        >
        <template v-slot:option="scope">
          <q-item
            v-bind="scope.itemProps"
            v-on="scope.itemEvents"
            >
            <q-item-section>
              <q-item-label caption>{{ scope.opt.name }}</q-item-label>
              <q-item-label >{{ scope.opt.description }}</q-item-label>
            </q-item-section>
          </q-item>
        </template>
      </q-select>

      <template v-if="!!value && !!value.type">
        <div v-for="(val, key) in value.type.construct"
             :key="key"
             class="row">
          <div class="col-2"> <q-chip>{{ key }}:</q-chip> </div>
          <div class="col"> <q-input v-model="value[key]" filled :label="val"/> </div>

        </div>
      </template>
    </div>
  </div>


    <q-btn v-if="modded && !!value.name && !!value.type " color="primary" label="Save Resource"
           v-on:click="saveThisResource" />
    <q-btn  color="primary" label="Cancel"
           v-on:click="cancel" />

    <!-- {{ value }} {{ makeResource() }} -->
</div>
</template>

<script>
import Network from 'components/Network.vue'
import  {
  listResourceTypes,
  saveResource,
  saveIdentity,
  listIdentities } from 'gambit-loader!../../public/glowdb.scm'

import axios from 'axios'
export default {
  name: 'Resource',
  props: ['network'],
  mounted: function () {
      listResourceTypes().then(l => {
        this.types = l
      })
    listIdentities().then(l => {
        this.identities = l
    })

    this.value.network = this.network;
  },
  methods: {
    inputResourceEvent() {
      this.modded = true
    },
    cancel() {
      this.$emit('cancel')
    },
    makeResource() {
      const v = this.value
      const res = {
        network: v.network,
        type: !!v.type ? v.type.name : null,
        name: v.name,
        description: v.description,
        exchangeCurrency: v.exchangeCurrency
      }
      if (v.type) {
        Object.entries(v.type.construct).map(([k, _]) => {
          res[k] = v[k]
        })
      }
      return res;
    },
    saveThisResource () {
      this.modded=false;
      const res = this.makeResource()
      saveResource(res)
      this.$emit('input', res)

      return res;

    },

  },
  data () {
    return {
      types: [],
      value: {},
      modded: false,
    }
  }
}
</script>
