<template>
<div class="q-pa-md" style="max-width: 350px">
  <q-list bordered separator>
    asset list {{ filterAssets().length }}
    <q-item v-for="asset in filterAssets()"
            v-bind:key="asset.id"
            clickable v-ripple>
      <q-item-section>
        <span v-if="asset.name"> {{ asset.name }} </span>
        <span v-if="asset.description"> {{ asset.description }} </span>
        <q-separator v-if="asset.name || asset.description"/>
        {{asset.resource}}
        <span v-if="asset.resource.name"> {{ asset.resource.name }} </span>
        <span v-if="asset.resource.description"> {{ asset.resource.description }} </span>
        <q-list dense v-if="asset.resource.type">
          <q-item dense>
            Path: {{ asset.resource.path }}
          </q-item>
          <q-item
                  v-for="(val, key) in asset.resource.type.description"
                  v-bind:key="key"
                  dense>
           {{ key }}:&nbsp;{{ val }}
          </q-item>
        </q-list>
          {{ asset }}  </q-item-section>
      <q-item-section side top>
        <q-item-label caption>type</q-item-label>
        <q-badge color="teal" v-if="asset.resource.type"
                 v-bind:label="asset.resource.type.name" />
        <q-item-label caption>&nbsp;net</q-item-label>
        <q-badge color="teal" v-bind:label="asset.resource.network" />
        </q-item-section>
      <q-item-section side top>
      </q-item-section>
   </q-item>
  </q-list>
</div>
</template>

<script>
import  { listAssets, findContact, findResource }  from 'gambit-loader!../../public/glowdb.scm'
export default {
  name: "AssetList",
  props:['contact'],
  async created () {
    const assets = await listAssets();
    this.assets = assets
    for (const key in assets) {
      const asset = assets[key];
      if (!!this.contact && asset.owner === this.contact.id) {
        asset.owner = this.contact;
      } else {
        const own = await findContact(asset.owner)
        asset.owner = own;
      }

      const res = await findResource(asset.resource)
      asset.resource = res;
      // console.log('asset', asset)

    }

  },
  data () {
    return {
      assets: [],
    }
  },

  methods: {
//     expandAsset(asset) {
//       findContact(asset.owner).then(c => {
//         asset.owner
// })

//     },
    renewAssets () {
      listAssets().then(l => {
        this.assets = l
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


    filterAssets() {
      if (this.contact) return this.contactAssets(this.contact);
      return this.assets

    },



  },
}
</script>
