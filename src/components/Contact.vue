<template>
  <div>
    <q-input v-model="name" label="Name"
             v-on:input="inputContactEvent"/>
    <q-input v-model="description" label="Description"
             v-on:input="inputContactEvent"/>

    <q-btn v-if="modded && id === null" color="primary" label="Save New Contact"
           v-on:click="saveThisContact" />
    <q-btn v-if="modded && id !== null" color="amber" label="Update Contact"
           v-on:click="saveThisContact" />




  </div>
</template>

<script>
import Network from 'components/Network.vue'
import  { saveContact }  from 'gambit-loader!../../public/glowdb.scm'
import { openDB, deleteDB, wrap, unwrap } from 'idb';

export default {
  name: 'Contact',
  methods: {
    makeContact() {

      return { id: this.id,
               name: this.name,
               description: this.description,
             }
    },
    inputContactEvent() {
      this.modded = true
      this.$emit('input', this.makeContact())
    },
    saveThisContact () {
      const ctct = this.makeContact();
      if (ctct.id === null) {
        ctct.id = randomUUID()
        this.id = ctct.id
      }
      this.inputContactEvent()
      this.modded=false;
      return saveContact(ctct);

    }

  },
  data () {
    return {
      id: null,
      name: null,
      description: null,
      value: null,
      modded: false



    }
  }
}
</script>
