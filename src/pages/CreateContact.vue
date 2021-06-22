<template>
  <q-page class="flex">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="perm_identity" to="/Contacts" />
        <q-breadcrumbs-el icon="build" label="Create contact" />
      </q-breadcrumbs>
    </div>
    <q-form class="q-pa-md">
      <q-input v-model="name"
               label="Name"
               autocorrect="off"
               spellcheck="false" />
      <br />
      <q-btn @click="save()"
             label="Save"
             type="submit"
             color="primary"/>
    </q-form>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    name: 'CreateContact',
    methods: {
        save(event) {
            console.log("Create new contact:", this.name);
            axios.post("/contacts/contact", {
                name: this.name
            }).then((response) => {
                console.log(response.data);
                this.$router.back();
            });
            false
        }
    },
    data() {
        return {
            name: null,
        }
    }
}
</script>
