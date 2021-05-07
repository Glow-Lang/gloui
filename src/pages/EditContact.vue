<template>
<div class="flex">
  <div class="q-pa-md q-gutter-sm" style="width:100%">
    <q-breadcrumbs>
      <q-breadcrumbs-el icon="home" to="/" />
      <q-breadcrumbs-el label="Edit Contact" icon="build" class="text-h5"/>
    </q-breadcrumbs>
  </div>
  <div v-if="err" class="q-pa-lg text-red">
    {{ err }}

  </div>

  <contact-select v-model="contact" @input="$forceUpdate()" />
  <div v-if="contact">
    asd
    <contact :value="contact" v-bind:contact="contact"/>
  </div>
        {{ contact }}
</div>
</template>

<script>
import  { saveContact, saveAsset, countObjectStore } from 'gambit-loader!../../public/glowdb.scm'
import Contact from 'components/Contact.vue'
import ContactSelect from 'components/ContactSelect.vue'
import axios from 'axios'

export default {
  name: 'EditContactPage',
  components: { Contact, ContactSelect },
  mounted() {
  },

  data() {
    return {
      contact: null,
      err: false
    }
  },
  methods: {
    isValid() {
      return !!this.address.number
    },
    saveNewContact() {
      const con = this.contact;
      const adds = this.addresses;

      con.id = randomUUID();

      console.log('Have Con!', con)

      return saveContact(con).then(() => {
        if (adds.length > 0) {
          adds.map(add => { saveAsset({ owner: con.id, address: add.id })})
        }
        this.newContact = con;
        this.newContactAddresses = adds;
        this.contact = {}
        this.addresses = []
        this.err = false
        return con
      })
    },
    addAnother() { this.newContact = null ; this.newContactAddresses = null }
  }
}
</script>
