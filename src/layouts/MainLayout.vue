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
          GloUI: Decentralized Applications across Blockchains
        </q-toolbar-title>

        <div>Gloui: 0.4.0 </div>
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
      <router-view />

      <div style="display: none">
        <gerbil-repl />
      </div>
    </q-page-container>
  </q-layout>
</template>

<script>
import 'gambit-loader!../../public/foo.scm'
import EssentialLink from 'components/EssentialLink.vue'
import GerbilRepl from 'components/GerbilREPL.vue'

import { openDB, deleteDB, wrap, unwrap } from 'idb';

import 'gambit-loader!../../public/bar.scm'
import  { listNetworks, addNetworks }  from 'gambit-loader!../../public/glowdb.scm'



globalThis.openDB = openDB;
globalThis.deleteDB = deleteDB;

globalThis.listNetworks = listNetworks;

const linksData = [
  {
    title: 'Glow Homepage',
    caption: 'glow-lang.org',
    icon: 'school',
    link: 'https://glow-lang.org/'
  },
  {
    title: 'Glow Documentation',
    caption: 'gitlab code',
    icon: 'code',
    link: 'https://glow-lang.org/#Takemetothecode'
  },
  {
    title: 'Discord Chat Channel',
    caption: 'invitation',
    icon: 'chat',
    link: 'https://discord.gg/pPMcqD6hWz'
  }
]

export default {
  name: 'MainLayout',
  components: {
    EssentialLink,
    GerbilRepl
  },
  created: function () {
    $glowdbPromise.then(() => {
      const nws = addNetworks()
      console.log("Added networks", nws)
      Promise.all(nws).then(() => {
        listNetworks().then(l => {
          l.sort((a,b) =>  {
            if (!b) { return true }
            else
            if (a.test === b.test) {
              return a.key < b.key
            } else {
              return (!a.test)
            }
          })

          console.log("Listed Networks", l)
          this.networks = l

        })
      })
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
