<template>
  <!-- List known contacts. -->
  <q-page class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="perm_identity" label="Contacts" />
      </q-breadcrumbs>
    </div>
    <div class="q-pa-md" style="max-width: 550px">
      <q-list bordered>
        <q-item-label>
          <q-btn no-caps unelevated
                 icon="person_add"
                 label="Create new contact"
                 :to="{name: 'create-contact'}" />
        </q-item-label>
        <q-item clickable
                v-for="contact in contacts"
                :key="contact.cid"
                :to="{name: 'contact', params: {cid: contact.cid}}"
        >
          <q-item-section avatar><q-avatar icon="perm_identity" /></q-item-section>
          <q-item-section>
            <q-item-label>{{contact.name}}</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </div>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    async created() {
        this.contacts = await axios.get("/contacts/contacts")
                                   .then((response) => response.data);
    },
    data() {
        return {
            contacts: [],
        }
    }
}
</script>
