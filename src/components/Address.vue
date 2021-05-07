<template>
  <div>
    Jas!
 <div class="row">
    <div class="col">
      <q-card class="q-px-lg q-pb-lg block q-mx-md" >
        <q-input v-model="value.number" label="Ethereum Address" style="min-width: 15em;"
                 hint="The number in '0x...' format. Optional if providing a secret key" />
        <q-input v-model="value.secret" type="password"
                 label="Secret" style="min-width: 15em;"
                 hint="The secret key in '0x...' format. If provided will generate the number."
                 @blur="findNumber"/>
        <q-input v-model="value.label" label="Label"
                 hint="Optional, but recommended: A simple way to label it"/>
      </q-card>
    </div>
  </div>
      <div class="full-width text-center q-mt-md">
        <q-btn v-if="value.number" label="Save Address" @click="save"/>
        <q-btn  label="cancel" @click="cancel"/>
      </div>
      </div>
</template>

<script>

import axios from 'axios'
export default {
 name: 'Address',
  data() {
    return {
      value: {},
    }
  },
  methods: {
    isValid() {
      return !!this.value.number
    },
    cancel () {
      this.value = {};
      this.$emit('cancel');
    },
    save() {
      this.$emit('input', this.value)
    },

    findNumber() {
      const sec = this.value.secret
      if (!!sec && sec.startsWith('0x')) {
        this.err = false
        console.log("finding number from", sec)
        return axios.post($glowServer+'/eth/address-from-identity', { key: sec } )
          .then(r => {
            const num = r.data
            this.value.number = num;
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
      const add = this.value;
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
    }
  }
}

</script>
