<template>
  <div>
    <q-input v-model="name" label="Name"
             v-on:input="inputResourceEvent"/>
    <q-input v-model="description" label="Description"
             v-on:input="inputResourceEvent"/>
    <network :value="network" @input="network = $event"
             />
    <q-select
      filled
      use-input v-model="path" :options="identities" option-label="address"
      emit-value
      map-options
      label="Path"
      color="teal"
      clearable
      options-selected-class="text-deep-orange"
      v-on:input="inputResourceEvent"
      @new-value="createNewIdentity"
      >
      <template v-slot:selected>
        <q-item v-if="path">
          <q-item-section v-if="path.name">
            <q-item-label caption>{{ path.address  }}</q-item-label>
            {{ path.name }}
          </q-item-section>
          <q-item-section v-else>
            {{ path.address }}
          </q-item-section>
        </q-item>
          <span v-else> </span>
        </template>
      <template v-slot:option="scope">
        <q-item
          v-bind="scope.itemProps"
          v-on="scope.itemEvents"
          >
          <q-item-section>
            <q-item-label caption>{{ scope.opt.address  }}</q-item-label>
            {{ scope.opt.name }}
          </q-item-section>
        </q-item>
      </template>

    </q-select>


    <q-select
      filled
      v-model="type"
      :options="types"
      option-label="name"
      emit-value
      map-options
      label="Type"
      color="teal"
      clearable
      options-selected-class="text-deep-orange"
      v-on:input="inputResourceEvent"
      >
      <template v-slot:option="scope">
        <q-item
          v-bind="scope.itemProps"
          v-on="scope.itemEvents"
          >
          <q-item-section>
            <q-item-label caption>{{ scope.opt.name }}</q-item-label>
          </q-item-section>
        </q-item>
      </template>
    </q-select>
    <q-input v-if=" type !== null" v-model="typeThing" :label="Object.keys(type.description)[0]"
      v-on:input="inputResourceEvent"
             filled />
    <q-btn v-if="modded && id === null" color="primary" label="Save New Resource"
           v-on:click="saveThisResource" />
    <q-btn v-if="modded && id !== null" color="amber" label="Update Resource"
           v-on:click="saveThisResource" />

    <q-dialog v-model="showNewIdentity">
      <q-layout view="Lhh lpR fff" container class="bg-white">
        <q-header class="bg-primary">
          <q-toolbar>
            <q-toolbar-title>
              Add new Identity?
            </q-toolbar-title>
            <q-btn flat v-close-popup v-on:click="resetIdentity" round dense icon="close" />
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
            <q-card padding >
            Is this path for a Private Identity?

            <q-btn label="Yes" v-on:click="createIdentityInput = true;
                                           createIdentityPublic = false;
                                           createIdentity.key = createIdentity.address;
                                           createIdentity.address = null;"/>
            <q-btn label="No" v-on:click="createIdentityPublic = true"/>
            </q-card>
            <br/>
            <q-card paddding v-if="createIdentityPublic">
              Do you want to save it as an indentity? This is useful if it will
              be used for more than one resource.
            <q-btn label="Yes" v-on:click="createIdentityInput = true"/>
            <q-btn label="No" v-on:click="makePublicIdentity"/>
            </q-card>

            <br/>
    <q-card padding v-if="createIdentityInput">
      <q-input v-model="createIdentity.name" label="Name" />
      <q-input v-if="!createIdentityPublic"
               v-model="createIdentity.key"
               label="Secret Private Key" />
      <q-input v-else v-model="createIdentity.address" label="Address" />
      <!-- <q-card padding v-if="!createIdentityPublic"> -->
      <!--   Optional: Enter the Address for this Identity. -->
      <!--   <br/>If left blank it will be -->
      <!--   found from the key. -->
      <!--   <q-input v-model="createIdentity.address" label="Address" /> -->
      <!-- </q-card> -->
        <q-btn v-if="createIdentityPublic" label="Save"
      v-on:click="makePublicIdentity"/> <q-btn v-else label="Save"
      v-on:click="makePrivateIdentity"/>

      <q-btn label="Cancel" v-on:click="resetIdentity"/>
    </q-card>
          </q-page>
        </q-page-container>
      </q-layout>
    </q-dialog>
    <!-- {{ value }} -->
  </div>
</template>

<script>
import Network from 'components/Network.vue'
import  {
  listResourceTypes,
  saveResource,
  saveIdentity,
  listIdentities } from 'gambit-loader!../../public/glowdb.scm'

import axios from 'axios'
export default {
  name: 'Resource',
  mounted: function () {
      listResourceTypes().then(l => {
        this.types = l
      })
    listIdentities().then(l => {
        this.identities = l
      })
  },
  methods: {
    makeResource() {
      const type = { name: this.type !== null ? this.type.name: null,
                     description: {}};
      if (this.type !== null) {
        type.description[Object.keys(this.type.description)[0]] = this.typeThing;
       }

      return { id: this.id,
               name: this.name,
               description: this.description,
               network: this.network,
               path: this.path,
               type: type
             }
    },
    inputResourceEvent() {
      this.modded = true
      this.$emit('input', this.makeResource())
   },
    saveThisResource () {
      const ctct = this.makeResource();
      if (ctct.id === null) {
        ctct.id = randomUUID()
        this.id = ctct.id
      }
      this.inputResourceEvent()
      this.modded=false;
      this.value = ctct;
      return saveResource(ctct);

    },
    resetIdentity() {
      this.createIdentity = {};
      this.createIdentityPublic = false;
      this.createIdentityInput = false
      this.showNewIdentity = false
    },
    createNewIdentity (val, done) {
      // specific logic to eventually call done(...) -- or not
      this.showNewIdentity = true;
      this.createIdentity.address = val;
      this.createIdentity.done = done;

      // done callback has two optional parameters:
      //  - the value to be added
      //  - the behavior (same values of new-value-mode prop,
      //    and when it is specified it overrides that prop –
      //    if it is used); default behavior (if not using
      //    new-value-mode) is to add the value even if it would
      //    be a duplicate
    },
    makePublicIdentity() {
      const cid = this.createIdentity;
      const id = { address: cid.address }
      if (!!cid.name) id.name = cid.name;
      this.createIdentity.done(id);
      if (!!id.name) this.saveNewIdentity(id)
      this.resetIdentity();
      return id;
    },
    makePrivateIdentity() {
      const cid = this.createIdentity;
      const id = { address: cid.address, name: cid.name, key: cid.key }
      this.createIdentity.done(id);
      this.saveNewIdentity(id);
      this.resetIdentity()

      if (!id.address) {
        axios.post($glowServer+'/eth/address-from-identity', id)
          .then(r => {
            const address = r.data
            id.address = address;
            saveIdentity(id);
          })
      }
      return id;
    },
    saveNewIdentity(id) {
     this.identities.push(id);
     saveIdentity(id)

    }

  },
  components: {  Network },
  data () {
    return {
      id: null,
      network: "pet",
      name: null,
      description: null,
      path: null,
      types: [],
      type: null,
      typeThing: null,
      value: null,
      modded: false,
      identities: [],
      showNewIdentity: false,
      createIdentity: {},
      createIdentityPublic: false,
      createIdentityInput: false
    }
  }
}
</script>
