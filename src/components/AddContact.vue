<template>
  <div>
    <q-input v-model="value.name" label="Name"
             v-on:input="inputContactEvent"/>
    <q-input v-model="value.description" label="Description"
             v-on:input="inputContactEvent"/>

  </div>
</template>

<script>
import Network from 'components/Network.vue'
import  { saveContact }  from 'gambit-loader!../../public/glowdb.scm'
import { openDB, deleteDB, wrap, unwrap } from 'idb';

export default {
  name: 'AddContact',
  methods: {
    makeContact() {

      return { id: this.id,
               name: this.name,
               description: this.description,
             }
    },
    inputContactEvent() {
      this.modded = true
      this.$emit('input', this.value)
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
      value: {},
      modded: false



    }
  }
}
</script>
