<template>
<div class="flex">
  <div class="q-pa-md q-gutter-sm" style="width:100%">
    <q-breadcrumbs>
      <q-breadcrumbs-el icon="home" to="/" />
      <q-breadcrumbs-el label="Add Contact" icon="build" class="text-h5"/>
    </q-breadcrumbs>
  </div>
  <div v-if="err" class="q-pa-lg text-red">
    {{ err }}
  </div>
  <template v-if="!!newContact">

     <q-card class="my-card" flat bordered>
      <q-card-section horizontal>
        <q-card-section class="q-pt-xs">
          <div class="text-overline">New Contact Added!</div>
          <div class="text-h5 q-mt-sm q-mb-xs">{{ newContact.label }}</div>
          <div class="text-caption">
            {{ newContact.number }}
            <q-separator />

            You can now look at the rolodex with this contact
            <template v-if="newContactAddresses">, make a transfer</template>, or
            create another contact.

            <ul v-if="newContactAddresses.length > 0">
            Addresses added under this contact:
              <li v-for="a in newContactAddresses"
                  v-bind:key="a.id"> {{ a.label }}
                <small> {{ a.number }}</small>
              </li>
            </ul>
          </div>
        </q-card-section>

        <q-card-section class="col-5 flex flex-center">
          <q-card class="q-pa-lg">
            Contact:
          <div class="text-h5 q-mt-sm q-mb-xs block">{{ newContact.name }}</div>

          <div class="text-caption"> {{ newContact.description }}</div>
          </q-card>
        </q-card-section>

      </q-card-section>

      <q-separator />

      <q-card-actions>
        <q-btn flat color="primary" @click="addAnother">
          Add Another Contact
        </q-btn>
        <q-btn flat color="primary" to="/AddAddress">
          Add an Address
        </q-btn>
        <q-btn flat color="primary" to="/AssetTransfer">
          Transfer some Assets
        </q-btn>
      </q-card-actions>
    </q-card>
  </template>

  <template v-else>
    <div class="row items-center justify-center full-width"
         >
    <div class="col-6 self-start">
      <q-card class="q-px-lg q-pb-lg block q-mx-md" >
        <add-contact v-model="contact" />
    <q-btn v-if="contact.name" color="primary" label="Save New Contact"
           v-on:click="saveNewContact" />

      </q-card>
    </div>
    <div class="col-6" v-if="addressesExist && !!contact && contact.name ">
      <q-card class="q-px-lg q-pb-lg q-pt-lg block q-mx-md ">
        <div v-if="contact.name">
              <q-card-section> <small class="text-weight-thin"> Description:</small>
                <address-select v-model="addresses" />

          </q-card-section>
        </div>
        <q-card-section>
          <div class="text-weight-light">Optional but recommended:  Addresses under this name
             </div>
        </q-card-section>
      </q-card>
    </div>
    <div class="col-6">&nbsp; </div>
  </div>
 <!-- {{ contact }} -->
  </template>
</div>
</template>

<script>
import AddContact from 'components/AddContact.vue'
import AddressSelect from 'components/AddressSelect.vue'
import  { saveContact, saveAsset, countObjectStore } from 'gambit-loader!../../public/glowdb.scm'

import axios from 'axios'

export default {
  name: 'AddContactPage',
  components: { AddContact, AddressSelect },
  mounted() {
    countObjectStore('address').then(n => {
      console.log('adddresses etxts?', n)
      this.addressesExist = n > 0
    })
  },

  data() {
    return {
      addresses: [],
      contact: {},
      err: false,
      newContact: null,
      newContactAddresses: null,
      addressesExist: false
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
