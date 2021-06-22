<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="perm_identity" label="Contacts" />
      </q-breadcrumbs>
    </div>
    <div class="q-pa-md" style="max-width: 550px">
      <q-list bordered>
        <q-btn no-caps unelevated
               icon="person_add"
               label="Create new contact"
               @click="$router.push('/CreateContact')" />

        <q-expansion-item
            v-for="contact in contacts"
            v-bind:key="contact.cid"
            group="contacts"
            icon="perm_identity"
            header-class="text-primary"
            default-closed
            :label="contact.name"
        >
          <q-card>
            <q-card-section
                v-for="identity in contact.identities"
                v-bind:key="identity.network + identity.address">
              {{ identity.network }}: {{ identity.address }}
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </q-list>
    </div>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    created() {
        console.warn("Contacts created");
        this.refresh();
    },
    methods: {
        async refresh() {
            this.contacts = await axios.get("/contacts/contacts")
                                       .then((response) => response.data);
            console.log("CONTACTS! ", this.contacts);
        },
    },
    data() {
        return {
            contacts: [],
        }
    }
}
</script>
