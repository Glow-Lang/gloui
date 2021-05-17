<template>
<div class="full-width">

  <div v-if="err" class="q-pa-lg text-red">
    {{ err }}
  </div>
  <div class="row">
    <div class="col-6">
      <h5> From: </h5>
      <contact-select
        v-model="from"
        ref="fromSelect"
        @input="popupAddContact($event, 'from')"
        />
      <!-- From: {{ from }} -->

      </div>
      <div class="col-6">
      <h5> To: </h5>
      <contact-select
        v-model="to"
        ref="toSelect"
        @input="popupAddContact($event, 'to')"
        />
      </div>
  </div>
  <div
       v-if="from" style="height:100%">
    <div
         v-for="(ass, key) in assets"
      v-bind:key="ass.id">
      <div class="row rounded-borders q-ma-sm">
        <!-- {{ ass }} {{ key }} -->
        <div class="col-6" style="height:100%" >
          <asset-select
            style="height:100%;overflow:hidden; text-overflow: elipsis;"
            v-model="ass.from"
            :ownerID="from.id"
            label="From this Address"
            mustHaveSecret
            @input="popupAddAsset($event, key, 'from')"
            :ref="assetRef('from', key)"
            />
          <!-- {{ key  }} -->
          <!-- {{ ass.from }} -->

        </div>

        <div class="col-6">
          <asset-select v-if="to"
                        v-model="ass.to" :ownerID="to.id" label="To this Address"
                        style="height:100%;"
                        @input="popupAddAsset($event, key, 'to')"
                        :ref="assetRef('to', key)"
                        />
          <!-- {{ ass.to }} -->
        </div>
      </div>
      <div class="row rounded-borders">
        <div class="col q-mx-sm">

          <!-- On This Network -->

          <network label="On this Network"
                   :value="ass.network"
                   @input="assetNetworkInput(key, $event)"
                   @select="assetNetworkSelect(key, $event)"
                   />

      </div>
      <div class="col" v-if="ass.network">
        <resource-select

          label="From this Resource"

          :network="ass.network"
          v-model="ass.resource"
          @input="assetResourceSelect(key, $event); $forceUpdate()"
          @cancel="cancelResource(key)"
          :ref="assetRef('resource', key)"/>
        <!-- {{ ass.resource }} -->
      </div>

      <div class="col q-mx-sm">
        <q-input outlined filled v-model="ass.amount" label="Send this Amount" @blur="verifyTransfer(key)" />
      </div>



      </div>
      <div class="q-mt-sm text-center full-width">
        <q-btn v-if="key > 0" icon="remove_circle" class="text-orange"
               label="Remove Asset Transfer" @click="removeAsset(ass)"/>
      </div>

  </div>
    <div class="row items-center" v-if="validTransfer()"
         style="height:100%"  >
    <div class="col-6 text-center" style="height:100%" >
      <q-btn icon="add_circle" class="text-teal" label="Add Another Asset Transfer" @click="addAsset()"/>
    </div>
    <div class="col-6 text-center">

      <q-btn icon="check" class="text-green"
             label="Perform Transaction"
             @click="performTransaction()"/>
    </div>
  </div>
    <div class="q-pa-md q-gutter-sm">
      {{ assets }}
      <!-- {{ transaction }} -->
<!-- persistent -->
    <q-dialog v-model="showProc" >
      <q-layout view="Lhh lpR fff" container class="bg-white">
        <q-header class="bg-primary">
          <q-toolbar>
            <q-toolbar-title>
              Transaction State: {{ transaction.state }}
            </q-toolbar-title>
            <q-btn flat v-close-popup :disable="!allowClose" round dense icon="close" />
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
            <h5 v-if="transaction.state !== 'finished'">
              Transfering from {{ transaction.remaining }} assets.</h5>
            <q-list v-for="xfer in transaction.transfers" :key="xfer.id">

              <q-item v-if="!!xfer.state">
                <q-card padding
                        :class="xfer.state === 'error' ? 'bg-red-2' : '' + 'q-pa-xl'">
                  <big v-if="xfer.state === 'error'"> ERROR: {{xfer.errorMessage}}</big>
                  <div class="text-h4"> {{ xfer.resource.description }}
                    <div class="text-h5 ful-width text-center"> net: {{ xfer.resource.network }}
                      <span class="q-ma-xl"> </span> {{ xfer.resource.name }}: {{xfer.amount}} </div>
                  </div>
                  <q-card bordered class="q-pa-m q-mt-m">
                    <br/>
                  from {{ xfer.from }}
                  <br> to {{ xfer.to }}
                  </q-card>
                  <div class="q-mt-xl"> <big>Opening Balance:</big>
                  <div class="row">
                    <div class="col"> From: </div>
                    <div class="col"> {{ xfer.openBalance.from }} </div>
                  </div>
                  <div class="row">
                    <div class="col"> To: </div>
                    <div class="col"> {{ xfer.openBalance.to }} </div>
                  </div>
                  </div>

                  <div v-if="xfer.state == 'finished'"> <big>Closing Balance:</big>
                  <div class="row">
                    <div class="col"> From: </div>
                    <div class="col"> {{ xfer.closeBalance.from }} </div>
                  </div>
                  <div class="row">
                    <div class="col"> To: </div>
                    <div class="col"> {{ xfer.closeBalance.to }} </div>
                  </div>
                  </div>
                  <div>State: {{ xfer.state }} </div>
                  <q-icon v-if="xfer.state === 'finished'"
                          name="check" style="float:right; font-size: 3em;"
                          class="text-green"/>

              </q-card> </q-item>
            </q-list>

          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>


    <q-dialog v-if="editContact" v-model="canEditContact" class="full-width">
      <q-layout view="Lhh lpR fff" container class="bg-white">
        <q-header class="bg-primary">
          <q-toolbar>
            <q-toolbar-title>
             Add Addresses to "{{ editContact.name }}"
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
            <contact :value="editContact" v-bind:contact="editContact"
                     :showDesc="false" @input="assetAdded" @cancel="cancelAddAsset"
                     @newAsset="newAddress"/>

          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>

    <q-dialog v-if="canAddContact" v-model="canAddContact" class="full-width">
      <q-layout view="Lhh lpR fff" container class="bg-white">
        <q-header class="bg-primary">
          <q-toolbar>
            <q-toolbar-title>
             Add New Contact
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
            <contact :value="addContact" v-bind:contact="addContact"
                     @input="contactAdded" @cancel="cancelAddContact"
                     :showAddresses="false"/>

          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>

     <!-- {{ assets }} -->

  </div>
  </div>
  </div>
</template>

<script>
import ContactSelect from 'components/ContactSelect.vue'
import ResourceSelect from 'components/ResourceSelect.vue'
import Contact from 'components/Contact.vue'
import AssetSelect from 'components/AssetSelect.vue'

import Network from 'components/Network.vue'
import axios from 'axios'

import  { findContact } from 'gambit-loader!../../public/glowdb.scm'

const coinKey = "bbe3ecfc186356e177696808b423aff6"

const coinLayer = axios.create({
   baseURL: 'https://api.coinlayer.com/',
   timeout: 10000,
  params: { access_key: coinKey }})

globalThis.coinLayer = coinLayer

export default {
  name: 'TransferAsset',
  components: { ContactSelect, Contact, AssetSelect, Network,
                ResourceSelect },
  methods: {
    cancelResource(key) {
      this.assets[key].resource = null
    },
    assetNetworkInput(key, nw) {
      const ass = this.assets[key]
      console.log('Start Input Asset Network', key, nw, ass, ass.selectedNetwork)
      this.assets[key].network = nw
      // this.assets[key].resource = null
      const ref = this.assetRef('resource', key)
      const res = this.$refs[ref]
      console.log("Have existing asset?", res, ref, this.$refs[ref])
      if (!!res && !!res[0]) {
        console.log('have resources', res[0])
        res[0].updateResources(nw).then(() => {
          console.log("res value", res)
          res[0].value = res[0].resources[1]
          ass.resource = res[0].value;

          this.$forceUpdate();
        })

      }
      console.log('Finish Input Asset Network')
    },
    assetAccountBalance(key, ass, where) {
      const which = ass[where]
      const add = which ? which.address.number : false
      const res = ass.resource;
      if (!!add && !!res) {
        const addressSelect = this.$refs['asset'+ where + key][0]
        addressSelect.balance = 'ask'
        console.log('refs again', this.$refs)
        return axios.post($glowServer+"/eth/balance",
                   {
                     address: add,
                     resource: res
                   })
          .then(resp => {
            console.log('Balance for', where, resp.data)
            which.balance = resp.data
            addressSelect.balance = true;
          })
          .catch(e => {
            addressSelect.balance = false
            this.err = e
          })
      } else {
        console.warn("NO ADDRESS OR RESOURCE FOR", where, ass, which, res)
      }
    },
    assetNetworkSelect(key, nw) {
      console.log('Selected a network', this.assets)
      this.assets[key].selectedNetwork = nw

    },
    assetResourceSelect(key, res, selectedR = false) {
      const ass = this.assets[key]
      console.log("resource selected", key, res)
      if (!!ass.selectedNetwork || selectedR) {
        this.assetAccountBalance(key, ass, 'from')
        this.assetAccountBalance(key, ass, 'to')
      }
    },
    popupAddAsset(e, key, where) {
      console.log("popupAddAsset", e, key, where)
      if (!!e && !!e.edit) {
      console.log('Editing:', e ,'On Key', key)
        const id = e.owner.id;
        findContact(id).then(c => {
          this.canEditContact = true;
          this.editContact = c
          this.editContactKey = key;
          this.editContactLocation = where;
          this.editContactRef = this.assetRef(where, key)
        })
      } else if (!e) {
        // the asset is null. Do we have an owner?
        //
        this.editContactRef = this.assetRef(where, key)
        this.$refs[this.assetRef(where, key)][0].cancel();
        console.log("Adding NULL asset", key, where, this[where],  this.assets[key], this.editContactRef)

      } else {
        this.assets[key][this.where] = e;
      }
    },
    cancelAddAsset() {
      this.canEditContact = false;
      const editEl = this.$refs[this.editContactRef][0]

      if (editEl.assets.length === 1 && editEl.assets[0].edit) {
        this[this.editContactLocation] = null;
        this.$refs[this.editContactLocation + 'Select'].updateAndSelect()
      }

      console.log('Cancel Add Asset', this.editContactRef, editEl.assets[0], this.$refs)
                  // this.$refs[this.editContactRef][0].cancel())

    },
    assetAdded(ass) {
      this.canEditContact = false;
     // console.log('added asset, reset:', this.assetRef(this.editContactKey), ass)
      // console.log('ref', this.editContactRef, this.$refs[this.editContactRef][0].cancel())
    },
    newAddress(add) {
      if (!!add) {
        console.log("Transer New asset", this.editContactKey, this.editContactLocation, add)
        this.assets[this.editContactKey][this.editContactLocation] = add;
        const ref = this.$refs[this.assetRef(this.editContactLocation, this.editContactKey)][0]
        console.log('xfaera ref', ref)
        ref.add(add);
        this.canEditContact = false;
        this.$forceUpdate()
      }
    },
    popupAddContact(e, where) {
      const whereAssets = Object.entries(this.$refs).filter(e => e[0].startsWith('asset' + where))
            .map(e => { const ret = e[1]; return !!ret[0] ? ret[0] : ret })

      if (whereAssets.length > 0 ) {
        whereAssets.map(a => a.cancel());
      }
        this.assets.map(a => a[where] = null)
      if (!!e && !!e.add) {
        this.canAddContact = true;
        this.addContactLocation = where
        this.addContact = { avatar: e.avatar };
        if (where === 'from') {
          this.from = this.addContact;
        } else {
          this.to = this.addContact;
        }
      } else {
        console.log("adding contact, must clear all ", where, ' addresses')
        console.log("where are they?", this.assets.map(a => a[where]))
      }
    },

    addContactSelect() {
      return this.addContactLocation === 'from'
        ? this.$refs.fromSelect : this.$refs.toSelect
    },
    contactAdded(c) {
      console.log("contact added?", c)
      this.canAddContact = false;
      this.addContactSelect().updateAndSelect(c);
      this.$forceUpdate()
    },
    cancelAddContact() {
      this.addContactSelect().updateAndSelect(null);
      this.canAddContact = false;
    },
    assetRef(loc, key) { return 'asset' + loc + key },
    validTransfer() {
      function isValid(ass) {
        return ass.from && ass.to && ass.amount
      }
      return this.assets.every(isValid);

    },
    addAsset() {
      this.assets.push({ from: null, to: null, amount: null, network: null } )
      console.log('Assets:', this.assets)
    },
    removeAsset(ass) {
      this.assets = this.assets.filter(a => a !== ass);
      console.log('Assets:', this.assets, this.validTransfer())
      this.$forceUpdate()
    },
    verifyTransfer(key) {
      const xfer = this.assets[key]
      const fromBalance = !!xfer.from.balance ? xfer.from.balance.balance : false
      const amount = xfer.amount

      if (!fromBalance) {
        return this.assetAccountBalance(key, xfer, 'from').then(() => this.verifyTransfer(key))
      }

      if (amount >= fromBalance) {
        this.err = "WARNING: account " +xfer.from.owner.name + ' (' + xfer.from.address.number +') may not have enough to send ' + amount;
        console.warn("amount", amount > fromBalance, fromBalance)
      }


      console.log("sending", xfer.amount, 'from', xfer.from, 'with balance', fromBalance)



    },
    performTransaction() {
      this.err = false;

      this.showProc = true
      const trans = { id: randomUUID(), assets: this.assets.slice() }

      console.warn('Here is the transaction:', trans)

      axios.post($glowServer+"/eth/transfer", trans)

        .then(r => {
          console.log('poty', r)
          this.transaction = r.data
          this.update = setTimeout(() => { this.updateTransaction() }, 500)
        })
        .catch(e => {
          console.error('Caught an error', e.response);

          this.err = e.response.data
        })
    },
    updateTransaction () {
      axios.get($glowServer+"/eth/transfer?id=" + this.transaction.id)

        .then(r => {
          const tranny = r.data
          this.transaction = tranny;
          const state = tranny.state;

          console.log('up', tranny)

          if (state !== "finished" && state !== "error") {
            console.log('state', state);
            clearTimeout(this.update)
            this.update = setTimeout(() => { this.updateTransaction() }, 500)
          } else {
            console.log('sloce!')
            this.allowClose = true
            clearTimeout(this.update)
          }
        })
        .catch(e => {
          console.error(e.result);
          this.err = e.result.data
        })

    }

  },
  data: () => {
    return {
      from: null,
      to: null,
      transfers: [],
      assets: [ { from: null, to: null, amount: null, network: null} ],
      transaction: false,
      showProc: false,
      allowClose: false,
      update: false,
      err: false,
      canEditContact: false,
      editContact: null,
      editContactKey: null,
      editContactLocation: null,
      canAddContact: false,
      addContact: null,
      addContactLocation: null
    }
  }
}
</script>
