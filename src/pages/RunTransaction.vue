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
    <template v-if="source && action">
      <h3 style="display: inline-flex; justify-content: center; flex-basis: 100%">
        <template v-if="source && dest && tokens">
          {{ source.name }} ({{ source.network }})
          <template v-if="action == 'transfer-to'">&rarr;</template>
          <template v-else-if="action == 'transfer-from'">&larr;</template>
          <template v-else>{{ action }}</template>
          {{ dest.name }} ({{ dest.network }})
        </template>
        <template v-if="action == 'faucet'">
          Fund {{ source.name }} ({{ source.network }})
        </template>
      </h3>
      <div v-if="txid && output">
        <div style="font-size: small; overflow: scroll; max-height: 300px; width: 550px;">
          <pre>{{output}}</pre>
        </div>
        <div v-if="status == -1" style="color: red">Transaction timed out.</div>
        <div v-else-if="status == 0" style="color: green">Transaction completed successfully.</div>
        <div v-else-if="status" style="color: orangered">Exited with status {{ status }}.</div>
        <div v-else><q-linear-progress indeterminate color="warning" class="q-mt-md" /></div>
      </div>
      <div v-else-if="action == 'faucet'">
        Turning on the faucet...
      </div>
      <div v-else-if="action == 'transfer-to' || action == 'transfer-from'">
        <q-form>
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
            <q-item>
              <q-btn @click="transfer()"
                   label="Transfer"
                   type="submit"
                   color="primary" />
            </q-item>
          </q-list>
        </q-form>
      </div>
      <div v-else>Unsupported action: {{ action }}</div>
    </template>
  </q-page>
</template>

<script>
const axios = require("axios");
export default {
    props: ["source", "action", "dest"],
    data() {
        return {
            amount: null,
            token: null,
            tokens: [],
            networks: [],
            txid: null,
            output: null,
            status: null,
        }
    },
    created() {
        axios.get("/contacts/networks")
             .then((response) => {
                 this.networks = response.data;
                 if (this.source) {
                     this.token = this.networks
                                      .find((network) => network.name == this.source.network)
                                      .native_token;
                 }
                 this.tokens = this.networks.map((network) => network.native_token);
                 this.tokens = [...new Set(this.tokens)]; // de-duplicate
                 this.tokens.sort();
             });

        // Turn on faucets right away, no need to wait for args.
        if (this.action == 'faucet') {
            this.faucet();
        }
    },
    methods: {
        faucet() {
            axios.post("/contacts/transaction", {
                action: this.action,
                args: {
                    source: this.source,
                }
            }).then((response) => {
                const txn = response.data;
                this.txid = txn.txid;
                console.log("Transaction", this.txid, "started");
                this.pollOutput();
            });
        },
        transfer() {
            axios.post("/contacts/transaction", {
                action: this.action,
                args: {
                    source: this.source,
                    dest: this.dest,
                    amount: this.amount,
                    token: this.token,
                }
            }).then((response) => {
                const txn = response.data;
                this.txid = txn.txid;
                console.log("Transaction", this.txid, "started");
                this.pollOutput();
            });
        },
        pollOutput() {
            const interval = setInterval(() => {
                axios.get("/contacts/transaction/" + this.txid.toString(), {})
                     .then((response) => {
                         const txn = response.data;
                         if (this.txid != txn.txid) {
                             throw("Transaction ID mismatch");
                         }
                         this.output = txn.output;
                         this.status = txn.status;
                         if (this.status) {
                             clearInterval(interval);
                         }
                     })
                     .catch((error) => {
                         if (error.response) {
                             console.log(error.response)
                         } else if (error.request) {
                             console.log(error.request);
                         } else {
                             console.log("Error:", error);
                         }
                         clearInterval(interval);
                     });
            }, 100);
        }
    }
}
</script>
