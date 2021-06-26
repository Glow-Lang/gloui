<template>
  <!-- Display one contact and its identities. -->
  <q-page class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="people_alt" to="/contacts" />
        <q-breadcrumbs-el v-if="contact" icon="perm_identity" :label="contact.name" />
      </q-breadcrumbs>
    </div>
    <template v-if="contact">
      <div class="q-pa-md">
        <h3>{{contact.name}}</h3>
        <q-separator />
        <q-list>
          <q-item v-if="!contact.identities.length">
            <q-item-label caption>No addresses found.</q-item-label>
          </q-item>
          <q-item clickable
                  :to="{
                      name: 'start-transaction',
                      params: {
                          source: {
                              cid: contact.cid,
                              name: contact.name,
                              network: identity.network,
                              address: identity.address
                          }
                      }
                  }"
                  v-for="(identity, index) in contact.identities" :key="index">
            <q-item-section avatar><q-avatar icon="contact_mail" /></q-item-section>
            <q-item-section>{{ identity.network }}</q-item-section>
            <q-item-section>{{ identity.address }}</q-item-section>
          </q-item>
          <q-item-label class="text-right">
            <q-separator /><br />
            <q-btn no-caps rounded unelevated
                   color="primary"
                   icon="edit"
                   label="Edit contact"
                   :to="{name: 'edit-contact', params: {cid: contact.cid}}" />
          </q-item-label>
        </q-list>
      </div>
    </template>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    props: ['cid'],
    data() {
        return {
            contact: null,
        }
    },
    created() {
        if (this.cid && !isNaN(parseInt(this.cid))) {
            console.log("Fetching contact", this.cid);
            axios.get("/contacts/contact/" + this.cid)
                 .then((response) => {
                     this.contact = response.data;
                 });
        }
    }
}
</script>
