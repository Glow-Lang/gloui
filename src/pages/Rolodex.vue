<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md" style="max-width: 350px">
    <q-list bordered>
      <q-expansion-item
        v-for="(contact, key) in contacts"
        v-bind:key="contact.id"
        group="somegroup"
        icon="explore"
        :label="contact.name"
        default-opened
        header-class="text-primary"
      >
        <q-card>
          <q-card-section>

            <!-- {{ contact.description }} -->
            <!-- <div class="q-pa-md" style="max-width: 350px"> -->
            <!--   <q-list bordered separator> -->
            <!--     <q-item v-for="asset in contactAssets(contact)" -->
            <!--             v-bind:key="asset.id" -->
            <!--             clickable v-ripple> -->
            <!--       <q-item-section> {{ asset }}  </q-item-section> -->
            <!--     </q-item> -->
            <!--   </q-list> -->
            <!-- </div> -->
            Why can't I pass contact? {{ contact.id }}
            <asset-list v-bind:contact="contacts[key]"/>
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator />

      <q-expansion-item group="somegroup" icon="perm_identity" label="Second" header-class="text-teal">
        <q-card>
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator />

      <q-expansion-item group="somegroup" icon="shopping_cart" label="Third" header-class="text-purple">
        <q-card>
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator />

      <q-expansion-item
        group="somegroup"
        icon="bluetooth"
        label="Fourth"
        header-class="bg-teal text-white"
        expand-icon-class="text-white"
      >
        <q-card class="bg-teal-2">
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </q-list>
     </div>
    {{ renewContacts()}}
     <!-- {{ resources }} -->
     <!-- {{ contacts }} -->
     {{ assets }}
</q-page>
</template>

<script>
import  { listContacts, listAssets, listResources}  from 'gambit-loader!../../public/glowdb.scm'
import   AssetList   from '../components/AssetList.vue'
globalThis.listAssets = listAssets;
console.warn("assetList", AssetList)
export default {
  created: function () {
    this.renewContacts()
  },
  components: { AssetList },
methods: {

renewContacts () {
  listContacts().then(l => {
        this.contacts = l
      })
      listAssets().then(l => {
        this.assets = l
     })
     listResources().then(l => {
        this.resources = l
      })

 },

 contactAssets(contact) {
  const assets = this.assets
   return assets.filter(a => {
     const own =  a.owner ;
     const id = (typeof own === 'string') ? own : own.id;
     return id === contact.id;
   })
 },



},
  data () {
    return {
      value: null,
      contacts: [],
      assets: [],
      resources: []
     }
  }
}
</script>
