<template>
     <q-card>
       <div class="q-pa-md row justify-evenly">
    <div class="q-gutter-y-md col-5" style="max-width: 45vw">
      <q-option-group
        v-model="panel"
        inline
        :options="[
          { label: 'New Resource', value: 'new' },
          { label: 'Existing Resource', value: 'existing' },
        ]"
      />
      <q-tab-panels v-model="panel" animated class="shadow-2 rounded-borders">
        <q-tab-panel name="new">
          <resource  :value="resource" @input="resource = $event" />
        </q-tab-panel>

        <q-tab-panel name="existing">
          <resource-select :value="resource" @input="resource = $event" />
        </q-tab-panel>

      </q-tab-panels>
    </div>
    <div class="q-gutter-y-md col-6">
      <q-option-group
        v-model="cpanel"
        inline
        :options="[
          { label: 'New Contact', value: 'cnew' },
          { label: 'Existing Contact', value: 'cexisting' },
        ]"
      />

      <q-tab-panels v-model="cpanel" animated class="shadow-2 rounded-borders">
        <q-tab-panel name="cnew">
          <span class="text-h5">Rolodex </span>
          <small> This is the "owner" of this asset. </small>
          <contact  :value="contact" v-on:input="inputContact" />
        </q-tab-panel>

        <q-tab-panel name="cexisting">
          <contact-select  :value="contact" v-on:input="inputContact" />
        </q-tab-panel>

      </q-tab-panels>
    </div>
       </div>
       <div>
    <div v-if="is_modded()">
      <q-btn v-if="modded && id === null" color="primary" label="Save New Asset"
           v-on:click="saveThisAsset" />
      <q-btn v-if="modded && id !== null" color="amber" label="Update Asset"
             v-on:click="saveThisAsset" />


    </div>
      <q-btn label="Go back home"
           to="/" />
      </div>

    </q-card>
</template>

<script>
import { openDB, deleteDB, wrap, unwrap } from 'idb';
import Resource from 'components/Resource.vue'
import ResourceSelect from 'components/ResourceSelect.vue'
import Contact from 'components/Contact.vue'
import ContactSelect from 'components/ContactSelect.vue'
import  { saveAsset }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  name: 'Asset',
  components: {  Resource,  ContactSelect, ResourceSelect, Contact },
  methods: {
    inputContact(event) {
      this.contact = event
      this.inputAssetEvent()
    },
    makeAsset() {

      return { id: this.id,
               owner: this.contact,
               resource: this.resource,
             }
    },
    inputAssetEvent() {
      this.modded = true
      this.$emit('input', this.makeAsset())
    },
    saveThisAsset () {
      const ctct = this.makeAsset();
      if (ctct.id === null) {
        ctct.id = randomUUID()
        this.id = ctct.id
      }
      this.inputAssetEvent()
      this.modded=false;
      this.value = ctct
      return saveAsset(ctct);

    },
    is_modded() {
      return this.modded && this.contact && this.resource
    }

  },
  data () {
    return {
      id: null,
      contact: null,
      resource: null,
      panel: 'new',
      cpanel: 'cnew',
      modded: false,
      value: null
    }
  }
}
</script>
