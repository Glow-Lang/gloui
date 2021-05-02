<template>
<q-page class="flex flex-center">
  <div style="width: 100%; text-align:center;">
    Welcome! Either <router-link to="/AddAddress"> add an Address</router-link>,
    <router-link to="/AddContact"> add a Contact</router-link>,
    or <router-link to="/AssetTransfer"> transfer some assets</router-link>
    <!-- , or <router-link to="/Rolodex"> view the rolodex</router-link>. -->
  </div>
  <div>
    <q-card padding>
      Server URL:
    <q-input v-model="glowServer" />
  </q-card>
  </div>
</q-page>

</template>

<script>
export default {
  name: 'PageIndex',
  data() { return {
    glowServer: globalThis.$glowServer
  } }
}
</script>
