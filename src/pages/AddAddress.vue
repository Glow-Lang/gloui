<template>
<div class="flex">
  <div class="q-pa-md q-gutter-sm" style="width:100%">
    <q-breadcrumbs>
      <q-breadcrumbs-el icon="home" to="/" />
      <q-breadcrumbs-el label="Add Address" icon="build" class="text-h5"/>
    </q-breadcrumbs>
  </div>
  <div v-if="err" class="q-pa-lg text-red">
    {{ err }}
  </div>
  <template v-if="!!newAddress">

     <q-card class="my-card" flat bordered>
      <q-card-section horizontal>
        <q-card-section class="q-pt-xs">
          <div class="text-overline">New Address Added!</div>
          <div class="text-h5 q-mt-sm q-mb-xs">{{ newAddress.label }}</div>
          <div class="text-caption">
            {{ newAddress.number }}
            <q-separator />

            You can now look at the rolodex with this address
            <template v-if="newAddressContact">, make a transfer</template>, or
            create another address.
          </div>
        </q-card-section>

        <q-card-section class="col-5 flex flex-center"
                        v-if="newAddressContact">
          <q-card class="q-pa-lg">
            Contact:
          <div class="text-h5 q-mt-sm q-mb-xs block">{{ newAddressContact.name }}</div>

          <div class="text-caption"> {{ newAddressContact.description }}</div>
          </q-card>
        </q-card-section>

      </q-card-section>

      <q-separator />

      <q-card-actions>
        <q-btn flat color="primary" @click="addAnother">
          Add Another Address
        </q-btn>
        <q-btn flat color="primary">
          View Rolodex
        </q-btn>
        <q-btn flat color="primary">
          Transfer
        </q-btn>
      </q-card-actions>
    </q-card>
    {{ newAddress }}
  </template>
  <template v-else>
  <div class="row">
    <div class="col">
      <q-card class="q-px-lg q-pb-lg block q-mx-md" >
        <q-input v-model="address.number" label="Number" style="min-width: 15em;"
                 hint="The number in '0x...' format. Optional if providing a secret" />
        <q-input v-model="address.secret" type="password"
                 label="Secret" style="min-width: 15em;"
                 hint="The secret in '0x...' format. If provided will generate the number."
                 @blur="findNumber"/>
        <q-input v-model="address.label" label="Label"
                 hint="Optional, but recommended: A simple way to label it"/>
      </q-card>
    </div>
    <div class="col">
      <q-card class="q-px-lg q-pb-lg q-pt-lg block q-mx-md ">
        <contact-select  v-model="contact"  />
        <div v-if="contact">
          <q-card-section v-if="contact.description"> <small class="text-weight-thin"> Description:</small>
            {{ contact.description }}
          </q-card-section>
        </div>
        <q-card-section>
          <div class="text-weight-light">Optional but recommended: The first contact
            index in the Rolodex to be associated with this address </div>
        </q-card-section>
      </q-card>
    </div>
  </div>
      <div class="full-width text-center q-mt-md">
        <q-btn v-if="address.number" label="Save Address" @click="saveNewAddress"/>
      </div>
</template>
</div>
</template>

<script>
import Contact from 'components/Contact.vue'
import ContactSelect from 'components/ContactSelect.vue'
import  { saveAddress, saveAsset } from 'gambit-loader!../../public/glowdb.scm'

import axios from 'axios'

export default {
  name: 'AddAddress',
  components: { ContactSelect },
  data() {
    return {
      address: {},
      contact: {},
      err: false,
      newAddress: null,
      newAddressContact: null,
    }
  },
  methods: {
    isValid() {
      return !!this.address.number
    },
    findNumber() {
      const sec = this.address.secret
      if (!!sec && sec.startsWith('0x')) {
        this.err = false
        console.log("finding number from", sec)
        return axios.post($glowServer+'/eth/address-from-identity', { key: sec } )
          .then(r => {
            const num = r.data
            this.address.number = num;
            this.$forceUpdate()
            return num
          })
          .catch(e =>  {
            console.error('ERR!!', e, e.response)
            this.err = e.response.data


          })
      } else if (!!sec) this.err = "Invalid 0x Hex: " + sec
    },
    saveNewAddress() {
      const add = this.address;
      const con = this.contact;

      add.id = randomUUID();

      return saveAddress(add).then(() => {
        if (!!con.id) saveAsset({ owner: con.id, address: add.id })
        this.newAddress = add;
        this.newAddressContact = con;
        this.contact = {}
        this.address = {}
        this.err = false
        return add
      })
    },
    addAnother() { this.newAddress = null ; this.newAddressContact = null }
  }
}
</script>
