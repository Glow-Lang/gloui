<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="leftDrawerOpen = !leftDrawerOpen"
        />

        <q-toolbar-title>
          Quasar App
        </q-toolbar-title>

        <div>Quasar v{{ $q.version }}</div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      content-class="bg-grey-1"
    >
      <q-list>
        <q-item-label
          header
          class="text-grey-8"
        >
          Essential Links
        </q-item-label>
        <EssentialLink
          v-for="link in essentialLinks"
          :key="link.title"
          v-bind="link"
        />
      </q-list>
    </q-drawer>

    <q-page-container>
      <transfer-asset />
      <router-view />
        <br/>
        <br/>
        <br/>
        <br/>
          <asset  :value="asset" @input="asset = $event" />
          <hr/>
          <resource-select />
          <contact  :value="contact" @input="contact = $event" />
          {{ contact }}


          <contact-select  :value="assetContact" @input="Assetcontact = $event" />

          {{ assetContact }}
          <resource  :value="resource" @input="resource = $event" />

          {{ resource }}


          <network :value="network" @input="network = $event"/>


      <!-- <gerbil-repl /> -->
    </q-page-container>
  </q-layout>
</template>

<script>
import 'gambit-loader!../../public/foo.scm'
import EssentialLink from 'components/EssentialLink.vue'
import GerbilRepl from 'components/GerbilREPL.vue'
import Network from 'components/Network.vue'
import Resource from 'components/Resource.vue'
import ResourceSelect from 'components/ResourceSelect.vue'
import Asset from 'components/Asset.vue'
import Contact from 'components/Contact.vue'
import ContactSelect from 'components/ContactSelect.vue'

import TransferAsset from 'components/TransferAsset.vue'
import { openDB, deleteDB, wrap, unwrap } from 'idb';

import 'gambit-loader!../../public/bar.scm'
import  { listNetworks }  from 'gambit-loader!../../public/glowdb.scm'


globalThis.openDB = openDB;
globalThis.deleteDB = deleteDB;

globalThis.listNetworks = listNetworks;
const linksData = [
  {
    title: 'Docs',
    caption: 'quasar.dev',
    icon: 'school',
    link: 'https://quasar.dev'
  },
  {
    title: 'Github',
    caption: 'github.com/quasarframework',
    icon: 'code',
    link: 'https://github.com/quasarframework'
  },
  {
    title: 'Discord Chat Channel',
    caption: 'chat.quasar.dev',
    icon: 'chat',
    link: 'https://chat.quasar.dev'
  },
  {
    title: 'Forum',
    caption: 'forum.quasar.dev',
    icon: 'record_voice_over',
    link: 'https://forum.quasar.dev'
  },
  {
    title: 'Twitter',
    caption: '@quasarframework',
    icon: 'rss_feed',
    link: 'https://twitter.quasar.dev'
  },
  {
    title: 'Facebook',
    caption: '@QuasarFramework',
    icon: 'public',
    link: 'https://facebook.quasar.dev'
  },
  {
    title: 'Quasar Awesome',
    caption: 'Community Quasar projects',
    icon: 'favorite',
    link: 'https://awesome.quasar.dev'
  }
];

export default {
  name: 'MainLayout',
  components: {
    EssentialLink,
    // GerbilRepl,
    Network,
    Resource,
    Contact,
    ContactSelect,
    Asset,
    ResourceSelect,
    TransferAsset
  },
  mounted: function () {
    $glowdbPromise.then(() => {
      listNetworks().then(l => this.networks = l)
    })
  },
  data () {
    return {
      leftDrawerOpen: false,
      essentialLinks: linksData,
      networks: [],
      network: "pet",
      resource: null,
      contact: null,
      assetContact: null,
      asset: null
    }
  }
}
</script>
