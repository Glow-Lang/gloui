<template>
  <!-- Run a transaction. -->
  <q-page class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el icon="people_alt" to="/contacts" />
        <q-breadcrumbs-el v-if="source"
                          icon="perm_identity"
                          :label="source.name"
                          :to="{name: 'contact', params: {cid: source.cid}}" />
        <q-breadcrumbs-el v-if="dest"
                          icon="perm_identity"
                          :label="dest.name"
                          :to="{name: 'contact', params: {cid: dest.cid}}" />
        <q-breadcrumbs-el icon="play_arrow" label="Run transaction" />
      </q-breadcrumbs>
    </div>
    <template v-if="source && dest && tokens">
      <h3>
        {{ source.name }}
        <template v-if="action == 'transfer-to'">&rarr;</template>
        <template v-else-if="action == 'transfer-from'">&larr;</template>
        <template v-else>{{ action }}</template>
        {{ dest.name }}
      </h3>
      <q-form class="q-pa-md" v-if="action == 'transfer-to' || action == 'transfer-from'">
        <q-list>
          <q-item>
            <q-input v-model="amount"
                     label="Amount"
                     autocorrect="off"
                     spellcheck="false" />
            <q-select v-model="token"
                      :options="tokens"
                      label="Token" />
          </q-item>
        </q-list>
      </q-form>
      <template v-else>Unsupported action: {{ action }}</template>
    </template>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    props: ["source", "action", "dest"],
    data() {
        return {
            amount: 0.0,
            token: null,
            tokens: [],
            networks: [],
        }
    },
    created() {
        axios.get("/contacts/networks")
             .then((response) => {
                 this.networks = response.data;
                 this.token = this.networks
                                  .find((network) => network.name == this.source.network)
                                  .native_token;
                 this.tokens = this.networks.map((network) => network.native_token);
                 this.tokens = [...new Set(this.tokens)]; // de-duplicate
                 this.tokens.sort();
             });
    }
}
</script>
