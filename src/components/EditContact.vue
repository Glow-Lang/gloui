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
      <q-item v-for="identity in identities"
              :key="identity.network + identity.address">
        <q-item-section>
          <!-- TODO: "Add new network" pseudo-option -->
          <q-select emit-value filled map-options
                    v-model="identity.network"
                    :options="networks"
                    option-value="name"
                    option-label="name"
                    label="Network" />
        </q-item-section>
        <q-item-section>
          <q-input v-model="identity.address"
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
            this.identities.splice(0, 0, {"network": "", "address": ""});
        },
        save() {
            if (this.cid) {
                console.log("Edit contact: ", this.cid, this.name);
                axios.put("/contacts/contact/" + this.cid.toString(), {
                    name: this.name,
                    identities: this.identities,
                }).then((response) => {
                    console.log("Response to edit: ", response.data);
                    this.$router.back();
                });
            } else {
                console.log("Create new contact:", this.name);
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
    async created() {
        if (this.cid && !isNaN(parseInt(this.cid))) {
            console.log("Fetching contact for editing", this.cid);
            this.contact = await axios.get("/contacts/contact/" + this.cid)
                                      .then((response) => response.data);
            this.identities = this.contact.identities.map((x) => Object.assign({}, x));
            if (!this.name && this.contact.name) {
                this.name = this.contact.name;
            } else if (this.name != this.contact.name) {
                // FIXME: Signal an error to the user.
                console.error("Oops! ", this.name, this.contact);
            } else {
                console.warn("Hmmm... ", this.contact);
            }
        }

        // Fetch shared networks list for Network selector.
        this.networks = await axios.get("/contacts/networks")
                                   .then((response) => response.data);
        console.log("Networks!", this.networks);
    }
}
</script>
