<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="link" label="Networks" />
      </q-breadcrumbs>
    </div>
    <div class="q-pa-md" style="max-width: 550px">
      <q-list bordered>
        <q-btn no-caps unelevated
               icon="add_link"
               label="Add new network"
               @click="$router.push('/AddNetwork')" />

        <q-expansion-item
            v-for="network in networks"
            v-bind:key="network.name"
            group="networks"
            icon="link"
            header-class="text-primary"
            default-closed
            :label="network.name"
        >
          <q-card>
            <q-card-section>{{ network.description }}</q-card-section>
            <q-card-section>{{ network.uri }}</q-card-section>
          </q-card>
        </q-expansion-item>
      </q-list>
    </div>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    async created() {
        this.networks = await axios.get("/contacts/networks")
                                   .then((response) => response.data);
    },
    data() {
        return {
            networks: [],
        }
    }
}
</script>
