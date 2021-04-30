<template>
  <div>
  <div class="row">
    <div class="col-6">
      <h5> From: </h5>
        <contact-select v-model="from" />

      </div>
      <div class="col-6">
      <h5> To: </h5>
        <contact-select v-model="to" />
      </div>
  </div>
  <div
       v-if="to && from" style="height:100%">
    <div class="row rounded-borders"
         style="border: 1px solid lightgrey; margin:0.5em; padding: 0.5em" v-for="(ass, key) in assets"
       v-bind:key="ass.id">
      <div class="col" style="height:100%" >
        <asset-select style="height:100%;overflow:hidden; text-overflow: elipsis;" v-model="ass.from" :ownerID="from" label="From this Asset"/>
      </div>
      <div class="col-2">
        <q-input outlined v-model="ass.amount" label="Send Amount" />
        <q-btn v-if="key > 0" icon="remove_circle" class="text-orange"
               label="Remove Asset Transfer" @click="removeAsset(ass)"/>
      </div>
      <div class="col">
        <asset-select v-if="to" v-model="ass.to" :ownerID="to" label="To this Asset"
                     style="height:100%;  overflow:hidden; text-overflow: elipsis;"/>
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

      {{ transaction }}

    <q-dialog v-model="showProc" persistent>
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
                <q-card style="padding: 1em;" :class="xfer.error ? 'bg-red-2' : ''">
                  <big v-if="xfer.error"> ERROR: {{xfer.error}}</big>
                  {{ xfer.currency }} {{xfer.amount}}
                  <br>from {{ xfer.from }}
                  <br> to {{ xfer.to }}
                  <div> <big>Opening Balance:</big>
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
  </div>
  </div>
  </div>
</template>

<script>
import ContactSelect from 'components/ContactSelect.vue'
import AssetSelect from 'components/AssetSelect.vue'

import axios from 'axios'


export default {
  name: 'TransferAsset',
  components: { ContactSelect, AssetSelect },
  methods: {
    validTransfer() {
      function isValid(ass) {
        return ass.from && ass.to && ass.amount
      }
      return this.assets.every(isValid);

    },
    addAsset() {
      this.assets.push({ from: null, to: null, amount: null  } )
      console.log('Assets:', this.assets)
    },
    removeAsset(ass) {
      this.assets = this.assets.filter(a => a !== ass);
      console.log('Assets:', this.assets, this.validTransfer())
      this.$forceUpdate()
    },
    performTransaction() {
      console.log(this.assets.slice())

      const trans = { id: randomUUID(), assets: this.assets.slice() }

      axios.post($glowServer+"/eth/transfer", trans)

        .then(r => {
          console.log('poty', r)
          this.transaction = r.data
          this.showProc = true
          this.update = setTimeout(() => { this.updateTransaction() }, 500)
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

    }

  },
  data: () => {
    return {
      from: null,
      to: null,
      transfers: [],
      assets: [ { from: null, to: null, amount: null } ],
      transaction: false,
      showProc: false,
      allowClose: false,
      update: false
    }
  }
}
</script>
