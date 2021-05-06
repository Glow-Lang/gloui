<template>
<q-page class="flex flex-center">
  <div class="text-h3" style="width: 100%; text-align:center;">
    Welcome! <br/> <br/> <q-separator/> <br/>
    <small><span v-if="contactsExist">Either </span>
      <router-link to="/AddContact">Add a Contact</router-link>
      <span v-if="contactsExist && !addressesExist"> or </span>
      <span v-else-if="contactsExist">, </span>
      <router-link v-if="contactsExist" to="/AddAddress"> Add an Address</router-link>
      <span v-if="addressesExist"> or </span>
      <router-link v-if="addressesExist" to="/AssetTransfer">Transfer some assets</router-link>
      <span>. </span>
    <!-- , or <router-link to="/Rolodex"> view the rolodex</router-link>. -->
    </small>
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
import  { countObjectStore } from 'gambit-loader!../../public/glowdb.scm'
export default {
  name: 'PageIndex',
 mounted() {
   countObjectStore('contact').then(n => {
     console.log('cntact count', n)
      this.contactsExist = n > 0
    })
    countObjectStore('address').then(n => {
     console.log('Address count', n, n > 0)
      this.addressesExist = n > 0
    })
  },
  data() { return {
    glowServer: globalThis.$glowServer,
    contactsExist: false,
    addressesExist: false,
  } }
}
</script>
