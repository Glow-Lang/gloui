<template>
<div v-if="value">
    <div class="row items-center full-height justify-center full-width ">
    <div class="col" v-if="showDesc">
    <q-card class="q-px-lg q-pb-lg block q-mx-md" >
    <q-input v-model="name" label="Name"
             v-on:input="inputContactEvent"/>
    <q-input v-model="description" label="Description"
             v-on:input="inputContactEvent"/>
 <q-item v-if="avatar">
        <q-item-section avatar>
          <q-avatar>
            <q-icon name="contact_mail"/>
            <!-- <img :src="avatar"> -->
          </q-avatar>
        </q-item-section>
        <q-item-section>
          <q-item-label caption> Avatar: Right now random, soon to be choose'able.</q-item-label>
        </q-item-section>
      </q-item>
      </q-card>
    </div>
    <div class="col" v-if="!!contact.name && showAddresses">
      <q-card class="q-px-lg q-pb-lg q-pt-lg block q-mx-md ">
        <div >


          <!-- Address Selection Here -->

          <q-card-section>

            <!-- {{ addresses }} -->
            <!--  -->
                <address-select v-if="addresses"
                                :selected="addresses"
                                ref="address"
                                @input="addresses = $event;inputContactEvent()"
                                @new="newAddress"
                                :ownerID="allowOtherAddresses ? null : contact.id"
                                />
                <div class="q-gutter-sm">
                  <q-checkbox v-model="allowOtherAddresses" label="Share other used or unused addresses?" />
                </div>

                <!-- {{ contact }} -->

          </q-card-section>
        </div>
        <q-card-section>
          <div class="text-weight-light">Optional but recommended:  Addresses under this name
             </div>
        </q-card-section>
      </q-card>


    </div>
    </div>
    <br/>
    <div class="row justify-center items-center">
      <div v-if="modded" class="col-4">
    <q-btn  color="amber" :label="!!contact.id ? 'Update Contact' : 'Save New Contact'"
           v-on:click="saveThisContact" />
      </div>
      <div class="col-4">
        <q-btn color="secondary" label="Cancel"
           v-on:click="cancel" />
      </div>
    </div>
  <!-- Contact: {{ value }} addresses: {{ addresses  }} {{ contact }} -->
</div>
<div v-else>
  &nbsp;
  <!-- Contact: {{ value }} addresses: {{ addresses  }} {{ contact }} -->
</div>
</template>

<script>
import Network from 'components/Network.vue'
import  { saveContact, listAssetEntities, saveAsset, deleteAsset  }  from 'gambit-loader!../../public/glowdb.scm'
import { openDB, deleteDB, wrap, unwrap } from 'idb';
import AddressSelect from 'components/AddressSelect.vue'

export default {
  name: 'Contact',
  components: { AddressSelect },
  props: { contact: {}, value: {},
           showDesc: { default: true },
           showAddresses: { default: true }},
  mounted: function () {
    const self = this;
    const isOwner = (asset) => {
      return asset.owner !== undefined && !!self.value && asset.owner.id === self.value.id
    }
    listAssetEntities().then(asses => {
      this.assets = asses.filter(isOwner);
      this.addresses = asses.filter(isOwner).map(a => { a.address.selected = true; return a.address} )
      console.log("entites", asses, this.addresses, this.value)
      this.oldAddresses = this.addresses;
      if (this.showAddresses && !!this.name) this.$refs.address.$forceUpdate()
    })
    this.name = this.value.name
    this.description = this.value.description
    this.avatar = this.value.avatar
  },
  methods: {
    inputContactEvent() {
      this.modded = true
    },
    newAddress(add) {
      console.log('New Addreww,', saveAsset, listAssetEntities)
      const newAsset = { owner: this.contact.id, address: add.id }
      saveAsset(newAsset).then(() => {
        listAssetEntities().then(es => {
          const newE = es.find( e => e.address.id === add.id )
          this.$emit('newAsset', newE)
        })
      })
    },
    cancel() {
      this.addresses = this.oldAddresses;
      this.$emit('cancel', this.contact)
    },
    undoAddresses() {
      this.addresses = this.oldAddresses;
    },
    makeContact() {
      return { name: this.name, description: this.description, avatar: this.avatar }
    },
    saveThisContact () {
      const ctct = this.contact;

      Object.assign(ctct, this.makeContact())
      if (!ctct.id) {
        ctct.id = randomUUID()
      }
      const adds = this.addresses;
      const delAdds = this.oldAddresses.filter(oa => !adds.find(a => a.id === oa.id))
      const delAsses = this.assets.filter(ass => !!delAdds.find(da => da.id === ass.address.id))

      console.log('Deleting', delAdds, delAsses)

        console.log('Saving', ctct)
      return saveContact(ctct).then(() => {
        console.log('Saved Contact', ctct)

        if (adds.length > 0) {
          Promise.all([
            ...delAsses.map(deleteAsset),
            ...adds.map(add => { saveAsset({ owner: ctct.id, address: add.id })})
          ]).then(() => {
            console.log('Input emited', ctct)
            this.$emit('input', ctct)
          })
        } else this.$emit('input', ctct)
      })

    }
  },
  data () {
    return {
      name: null,
      description: null,
      avatar: false,
      modded: false,
      addresses: [],
      oldAddresses: [],
      assets: [],
      allowOtherAddresses: false,





    }
  }
}
</script>
