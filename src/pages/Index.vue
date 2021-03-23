<template>
<q-page class="flex">
  <div style="width: 100%">
    <div v-show="error" class="text-negative">
      {{ error }}
      <q-btn  label="Dismiss" @click="error = !error"/>
      <q-btn  label="Reload" @click="reloadPage()"/>
    </div>
    <q-splitter
      v-model="splitterModel"
      class='bg-blue-grey-1'
      >

      <template v-slot:before>
        <q-tabs
          v-model="tab"
          vertical
          active-bg-color='grey-12'
          >
          <br>
          <h5 class="text-center" style="margin:0">Trusted DApp Library</h5>
          <q-tab name="atob" label="Send Tokens from A to B" no-caps />
          <q-tab name="erc20" label="ERC20 Transfer" no-caps />
          <q-tab name="signature" label="Buy Signature" no-caps />
          <q-tab name="coinflip" label="Coin Flip" no-caps />
          <q-tab name="assetswap" label="Asset Swap" no-caps/>
        </q-tabs>
      </template>

      <template v-slot:after>
        <q-splitter v-model="chainModel">

          <template v-slot:before>
            <div class="bg-white">
              <!--<br> <div class="text-h4 text-center">Contract Inputs</div>-->
              <q-select
                filled
                v-model="tags"
                multiple
                :options="allTags"
                use-chips
                stack-label
                label="Context Tags"
                />
              <q-tab-panels
                v-model="tab"
                animated
                swipeable
                vertical
                transition-prev="jump-up"
                transition-next="jump-up"
                >
                <q-tab-panel name="erc20">
                  <h5>ERC20 Transfers</h5>
                  <address-select :tags="tags"
                                  v-model="fromAddress"
                                  :book="fromAddressBook"
                                  label="Select From: Address"
                                  />
                  <br/>
                  <address-select :tags="tags"
                                  v-model="toAddress"
                                  :book="toAddressBook"
                                  new-value-mode="add"
                                  label="Select To: Address"
                                  />
                  <br/>
                  <div>
                    <amount v-model="amount" class="inline-block" style="min-width: 8rem"/>
                    <ERC20Asset v-model="ERC20Asset"
                                :options="ERC20Contracts"
                                class="inline-block" style="min-width: 8rem"
                                />
                  </div>
                </q-tab-panel>
                <q-tab-panel name="signature">
                  <div class="text-h4 q-mb-md">Address Book Testing</div>
                </q-tab-panel>

                <q-tab-panel name="atob">
                  <h5> Send Tokens from A to B</h5>
                  <address-select :tags="tags"
                                  v-model="fromAddress"
                                  :book="fromAddressBook"
                                  label="Select From: Address"
                                  />
                  <br/>
                  <address-select :tags="tags"
                                  v-model="toAddress"
                                  :book="toAddressBook"
                                  new-value-mode="add"
                                  label="Select To: Address"
                                  />
                  <br/>
                  <div>
                    <amount v-model="amount" class="inline-block" style="min-width: 8rem"/>
                    <asset v-model="assetClass" class="inline-block" style="min-width: 8rem"
                           :options="assetClasses"/>
                    <target v-model="target" class="inline-block" style="min-width: 8rem"
                            :options="targets"/>

                    <exchange-rate v-model="amount" :target="target" :asset="assetClass"
                                   class="text-primary float-right"
                                   style="padding-right: 2em;margin-top:1rem;"/>
                  </div>

                </q-tab-panel>

                <q-tab-panel name="movies">
                  <div class="text-h4 q-mb-md">Movies</div>
                </q-tab-panel>
              </q-tab-panels>
              <hr/>

              <!-- <div class="text-h4 text-center">Contract</div>
              <pre><code>
                  {{ contract }}
              </code></pre> -->
            </div>
          </template>

          <template v-slot:after>
            <div class="bg-blue-grey-1 text-center" style="height: 100%">
              <br/>
              <q-select filled style="width:92%; margin: auto"
                        v-model="network" :options="networks" label="Network" >
                <template v-slot:option="scope">
                  <q-item
                    v-bind="scope.itemProps"
                    v-on="scope.itemEvents"
                    >
                    <q-item-section>
                      <q-item-label v-html="scope.opt.label" />
                      <q-item-label caption>{{ scope.opt.description }}</q-item-label>
                    </q-item-section>
                    <q-item-section avatar>
                      {{ scope.opt.shortName }}
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
                  <q-btn color="white" text-color="black" label="Send" style="width:92%"
                         @click="deploy" :disable="notValid()"/>
                  <q-btn v-show="process && !dialog"
                         color="white" text-color="black" label="Show Last Process Output"
                         style="width:92%" @click="dialog = !dialog"/>
                  <q-dialog
                    v-model="dialog"
                    persistent
                    :maximized="maximizedToggle"
                    transition-show="slide-up"
                    transition-hide="slide-down"
                    >
                    <q-card class="bg-primary text-white">
                      <q-bar>
                        <q-space />

                        <q-btn dense flat icon="minimize" @click="maximizedToggle = false" :disable="!maximizedToggle">
                          <q-tooltip v-if="maximizedToggle" content-class="bg-white text-primary">Minimize</q-tooltip>
                        </q-btn>
                        <q-btn dense flat icon="crop_square" @click="maximizedToggle = true" :disable="maximizedToggle">
                          <q-tooltip v-if="!maximizedToggle" content-class="bg-white text-primary">Maximize</q-tooltip>
                        </q-btn>
                        <q-btn dense flat icon="close" v-close-popup>
                          <q-tooltip content-class="bg-white text-primary">Close</q-tooltip>
                        </q-btn>
                      </q-bar>

                      <q-card-section >
                        <div class="text-h6">{{ status() }}</div>
                      </q-card-section>

                      <q-card-section class="q-pt-none">
                        <code v-show="!notValid()" style="white-space: pre-wrap">

                            {{ output }}
                        </code>
                      </q-card-section>
                    </q-card>
                  </q-dialog>
              <!--   </q-tab-panel> -->
              <!-- </q-tab-panels> -->
              </div>
          </template>

        </q-splitter>
      </template>

    <br>
    </q-splitter>
    <hr/>
    <!-- {{ fromAddress }} -->
  </div>
</q-page>
</template>

<script>
import {
  AddressSelect,
  Amount,
  Asset,
  Target,
  ExchangeRate,
  coinlayerList,
  // getServerHome,
  postTransfer,
  postProcess
} from '../assets/widgets.ss'

import { listIdentities } from '../assets/identities.ss'
import { listContacts } from '../assets/contacts.ss'
import { listEvmNetworks } from '../assets/ethereum-networks.ss'
import {
  ERC20Contracts,
  ERC20Asset,
  ERC20Balance,
  ERC20Transfer
} from '../assets/erc20.ss'

window.GloUI = { listIdentities, ERC20Balance }
import {
  findAddressesByName,
  feesAndTotals
} from '../assets/addressBook.ss'

import RTS from 'gxjs'
// RTS.host_function2scm = RTS.function2scm
window.GXJS = RTS

const choices = ['Rock', 'Paper', 'Scissors']

const depAddresses =
      [
        '0xbc1qedg2n3mqsgxrrff2xdn3wxqwy6f8434xkz45v9',
        '0x18VwoRVyjTYoH4TCvxkkQxbk5WLMZa6eTN',
        '0x3J1j74SGjcbX6bVXqtZDrKy8p9P8i9AGR4'
      ]

const amountOptions = ['All at From: Address']

export default {
  name: 'PageIndex',
  components: { AddressSelect, Amount, Asset, Target, ExchangeRate, ERC20Asset },
  created: function () {
    this.$q.loading.show({
      message: 'Connecting to server <b>"http://localhost:6741/"</b> and loading data.<br/><span class="text-info">Hang on, may take a while ...</span>'

    })
    coinlayerList().then(l => {
      this.assetClasses = Object.values(l.crypto).map(c => {
        c.label = c.name_full
        return c
      })

      for (const [key, value] of Object.entries(l.fiat)) {
        this.targets.push({ symbol: key, name: value, label: key + ': ' + value })
        // console.log(`${key}: ${value}`)
      }
    }).catch(e => {
      this.$q.loading.hide()
      console.error('Error connecting to Coinlayer erver', e)
      this.error = new Error('Error for coinlayer Server ' + e.message)
    })

    this.assetClasses.unshift({ label: 'Native Token (ADA)', symbol: 'ADA' })

    listIdentities().then(ids => {
      console.warn('identites', ids)
      ids.map(c => {
        c.label = c.name + ' ' + c.address + '<br>&nbsp;&nbsp;&nbsp;&nbsp; tags: [' + c.tags.join(',') + ']'
        this.allTags = [...new Set([...this.allTags, ...c.tags])]
      })
      this.fromAddressBook = ids
    })

    listContacts().then(contacts => {
      contacts.map(c => {
        c.label = c.name + ' ' + c.address + '<br> &nbsp;&nbsp;&nbsp;&nbsp; tags: [' + c.tags.join(',') + ']'
        this.allTags = [...new Set([...this.allTags, ...c.tags])]
      })
      this.toAddressBook = contacts
    })

    listEvmNetworks().then(networks => {
      networks.map(n => { n.label = n.name })
      this.networks = networks
      this.network = networks[0]
      this.$q.loading.hide()
    }).catch(e => {
      this.$q.loading.hide()
      console.error('Error connecting to server', e)
      this.error = new Error('Error for Glow Server @ localhost:6741 ' + e.message)
    })

    ERC20Contracts().then(e => {
      e.data.map(c => {
        c.label = c.symbol + ' ' + c.description + '<br> &nbsp;&nbsp;' + c.address
        console.warn('ctnct', c)
        return c
      })

      this.ERC20Contracts = e.data
    }).catch(e => {
      console.error(e)
    })

    console.warn('conrtsacts:', this.ERC20Contracts)
  },
  computed: {
    //    fromAddressBook: function () { return theFromAddressBook },
    exchangeValue: function () {
      return this.amount * 3.14159
    },
    feesAndTotals: function () { return feesAndTotals(this.amount, this.assetClass, this.blockchain) }

  },
  methods: {
    // fromAddressBook: function () { return theFromAddressBook },
    findAddressesByName,
    status: function () {
      return this.process ? this.process.thread.state : undefined
    },
    notValid: function () {
      return this.toAddress === null || this.fromAddress === null || this.amount === null
    },
    deploy: function () {
      console.warn('deploy', this.tab)
      if (this.tab === 'atob') {
        this.deployAtoB()
      } else if (this.tab === 'erc20') {
        this.deployERC20Transfer()
      }
    },
    processProcess () {
      postProcess({ uuid: this.process.uuid })
        .then(r => {
          this.process = r.data
          this.output = this.process.output.join('\n')
        })
      const state = this.process.thread.state
      if (state === 'running' || state === 'waiting') {
        setTimeout(this.processProcess, 2000)
      }
    },
    deployAtoB: function () {
      const AtoB = {
        from: this.fromAddress,
        to: this.toAddress,
        amount: this.amount,
        token: this.assetClass,
        network: this.network
      }
      console.warn('ÅtoB', AtoB)
      postTransfer(AtoB).then(r => {
        console.log('Transfer Posted!!', r)
        this.process = r.data
        this.dialog = true
        setTimeout(this.processProcess, 1000)
      }).catch(e => {
        console.error('ATOB ERR', e)
        this.error = e
      })
    },
    deployERC20Transfer: function () {
      const xfer = {
        from: this.fromAddress,
        to: this.toAddress,
        amount: this.amount,
        token: this.ERC20Asset,
        network: this.network
      }
      ERC20Transfer(xfer).then(r => {
        console.log('ERC20 result', r)
        this.process = r
        this.dialog = true
        setTimeout(this.processProcess, 1000)
      })
    },
    reloadPage () {
      window.location.reload()
    }
  },
  data () {
    return {
      error: false,
      allTags: [],
      tags: [],
      tab: 'atob',
      depTab: 'deploy',
      splitterModel: 20,
      chainModel: 60,
      network: null,
      networks: [],
      fromAddressBook: [],
      fromAddress: null,
      toAddress: null,
      toAddressBook: [],
      depAddresses,
      depAddress: null,
      choice: null,
      choices,
      amount: null,
      amountOptions: amountOptions,
      assetClass: { label: 'ADA: Cardano Token', symbol: 'ADA' },
      assetClasses: [],
      target: { label: 'CAD: Canadian Dollar', symbol: 'CAD' },
      targets: [],
      taxUnit: 'CAD',
      output: 'Waiting to deploy...',
      contract: 'Waiting for contract...',
      process: false,
      dialog: false,
      maximizedToggle: true,
      ERC20Asset: null,
      ERC20Contracts: ['asd'],
      ERC20FromBalance: false
    }
  }
}

</script>
