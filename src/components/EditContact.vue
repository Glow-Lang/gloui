<template>
  <!-- Edit a contact and its associated identities. -->
  <q-form class="q-pa-md">
    <q-input v-model="name"
             label="Name"
             autocorrect="off"
             spellcheck="false" />
    <br />
    <q-list>
      <q-item-label>
        <q-btn no-caps unelevated
               @click="addAddress()"
               label="Add new address"
               icon="contact_mail" />
      </q-item-label>
      <q-item v-for="(identity, index) in identities" :key="index">
        <q-item-section>
          <!-- TODO: "Add new network" pseudo-option -->
          <q-select emit-value filled map-options
                    v-model="identities[index].network"
                    :options="networks"
                    option-value="name"
                    option-label="name"
                    label="Network" />
        </q-item-section>
        <q-item-section>
          <q-input v-model="identities[index].address"
                   label="Address"
                   autocorrect="off"
                   spellcheck="false" />
        </q-item-section>
      </q-item>
    </q-list>
    <br />
    <q-btn @click="save()"
           label="Save"
           type="submit"
           color="primary"/>
  </q-form>
</template>

<script>
const axios = require("axios");
export default {
    name: 'EditContact',
    props: ['cid'],
    data() {
        return {
            name: null, // model (provisional)
            identities: [], // model (provisional)
            contact: null, // from server (canonical)
            networks: [], // from server (canonical)
        }
    },
    methods: {
        addAddress() {
            this.identities.unshift({"network": "", "address": ""});
        },
        save() {
            if (this.cid) {
                axios.put("/contacts/contact/" + this.cid.toString(), {
                    name: this.name,
                    identities: this.identities,
                }).then((response) => {
                    console.log("Contact", this.cid, "updated.");
                    this.$router.back();
                });
            } else {
                axios.post("/contacts/contact", {
                    name: this.name,
                    identities: this.identities,
                }).then((response) => {
                    console.log(response.data);
                    this.$router.back();
                });
            }
            false
        }
    },
    created() {
        // Fetch contact & identities for editing.
        if (this.cid && !isNaN(parseInt(this.cid))) {
            axios.get("/contacts/contact/" + this.cid)
                 .then((response) => {
                     this.contact = response.data
                     this.identities = this.contact.identities.map((x) => Object.assign({}, x));
                     if (!this.name && this.contact.name) {
                         this.name = this.contact.name;
                     } else if (this.name != this.contact.name) {
                         console.error("Name mismatch: ", this.name, this.contact);
                     }
                 });
        }

        // Fetch networks list.
        axios.get("/contacts/networks")
             .then((response) => {
                 this.networks = response.data;
             });
    }
}
</script>
