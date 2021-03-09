<template>
<q-page class="flex">
  <div style="width: 100%">

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
          <q-tab name="signature" label="Buy Signature" no-caps />
          <q-tab name="coinflip" label="Coin Flip" no-caps />
          <q-tab name="assetswap" label="Asset Swap" no-caps/>
          <img alt="MuKn logo" src="~assets/mukn-name-2.png">
        </q-tabs>
      </template>

      <template v-slot:after>
        <q-splitter v-model="chainModel">

          <template v-slot:before>
            <div class="bg-white">
              <br>
              <div class="text-h4 text-center">Contract Inputs</div>
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
                                 class="text-h5 text-primary float-right"
                                 style="padding-right: 2em;margin-top:1rem;"/>
                  </div>

                  <!-- <q-select -->
                  <!--   filled -->
                  <!--   v-model="fromAddress" -->
                  <!--   :options="fromAddressBook" -->
                  <!--   use-input -->
                  <!--   use-chips -->
                  <!--   label="From: Address" /> -->

                  <br/>
                  <!-- <q-select -->
                  <!--   label="To: Address" -->
                  <!--   filled v-model="toAddress" -->
                  <!--   :options="toAddressBook" -->
                  <!--   use-input -->
                  <!--   use-chips -->
                  <!--   new-value-mode="add" -->

                  <!--   input-debounce="0" -->
                  <!--   @filter="filterTo" -->
                  <!--   /> -->
                  <!-- <br/> -->
                  <!-- <q-select filled v-model="choice" :options="choices" label="Choice" /> -->
                  <br/>

                  <!-- <q-select -->
                  <!--   filled v-model="amount" label="Amount" :options="amountOptions" -->
                  <!--   use-input -->
                  <!--   use-chips -->
                  <!--   new-value-mode="add" -->
                  <!--   class="inline-block" -->
                  <!--   /> -->
                  <!-- <q-select filled v-model="assetClass" :options="assetClasses" label="Asset" -->
                  <!--           class="inline-block"/> -->

                  <!-- <span v-if="amount" class="text-h5 text-primary float-right"> -->
                  <!--   ${{exchangeValue}} {{taxUnit}} </span> -->

                  <!-- <div v-if="amount" class="text-weight-light text-h6"> -->
                  <!--   <ul> -->
                  <!--     <li><label> Fees: </label> {{feesAndTotals.fee}}</li> -->
                  <!--     <li><label> Total: </label> {{feesAndTotals.total}} {{assetClass}} </li> -->
                  <!--   </ul> -->
                  <!-- </div> -->
                </q-tab-panel>

                <q-tab-panel name="movies">
                  <div class="text-h4 q-mb-md">Movies</div>
                </q-tab-panel>
              </q-tab-panels>
              <hr/>

              <div class="text-h4 text-center">Contract</div>
              <pre><code>
                  {{ contract }}
              </code></pre>
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
              <q-item-label caption>{{ scope.opt.url }}</q-item-label>
            </q-item-section>
            <q-item-section avatar>
              {{ scope.opt.symbol }}
            </q-item-section>
          </q-item>
                 </template>
              </q-select>
              <br/>
              <!-- <q-btn color="white" text-color="black" label="Compile" style="width:92%"/> -->
              <br/>
              <!-- <q-tabs -->
              <!--   v-model="depTab" -->
              <!--   dense -->
              <!--   class="text-grey" -->
              <!--   shrink -->
              <!--   active-color="primary" -->
              <!--   indicator-color="primary" -->
              <!--   align="justify" -->
              <!--   narrow-indicator -->
              <!--   style="padding-top: 1em" -->
              <!--   > -->
              <!--   <q-tab name="validate" label="Validate" /> -->
              <!--   <q-tab name="download" label="Download" /> -->
              <!--   <q-tab name="deploy" label="Deploy" /> -->
              <!-- </q-tabs> -->

              <!-- <q-separator /> -->

              <!-- <q-tab-panels v-model="depTab" animated class="bg-blue-grey-1 text-center"> -->
              <!--   <q-tab-panel name="validate"> -->
              <!--     Lorem ipsum dolor sit amet consectetur adipisicing elit. -->
              <!--   </q-tab-panel> -->

              <!--   <q-tab-panel name="download"> -->
              <!--     <div class="text-h6">Alarms</div> -->
              <!--     Lorem ipsum dolor sit amet consectetur adipisicing elit. -->
              <!--   </q-tab-panel> -->

              <!--   <q-tab-panel name="deploy" class="text-center"> -->
                  <!-- <q-select filled v-model="depAddress" -->
                  <!--           :options="depAddresses" -->
                  <!--           label="Address" -->
                  <!--           style="width:92%; margin: auto"/> -->
                  <!-- <br> -->
                  <q-btn color="white" text-color="black" label="Deploy" style="width:92%"
                         @click="deploy" :disable="notValid()"/>

                  <pre v-show="!notValid()"><code>
                      {{ output }}
                      {{ process }}
                  </code></pre>
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
  getListIdentities,
  coinlayerList,
  getServerHome,
  postTransfer,
  postProcess
} from '../assets/widgets.ss'

import {
  findAddressesByName,
  feesAndTotals
} from '../assets/addressBook.ss'

const choices = ['Rock', 'Paper', 'Scissors']

const depAddresses =
      [
        '0xbc1qedg2n3mqsgxrrff2xdn3wxqwy6f8434xkz45v9',
        '0x18VwoRVyjTYoH4TCvxkkQxbk5WLMZa6eTN',
        '0x3J1j74SGjcbX6bVXqtZDrKy8p9P8i9AGR4'
      ]

const tags = ['rps', 'whodo', 'unamed one', 'moonshine', 'crazy', 'kitty cats']

const amountOptions = ['All at From: Address']

export default {
  name: 'PageIndex',
  components: { AddressSelect, Amount, Asset, Target, ExchangeRate },
  created: function () {
    getListIdentities(book => {
      console.log('JS book', book)
      this.fromAddressBook = book
    }).catch(e => { console.log('err, et', e) })

    coinlayerList().then(l => {
      this.assetClasses = Object.values(l.crypto).map(c => {
        c.label = c.name_full
        return c
      })

      for (const [key, value] of Object.entries(l.fiat)) {
        this.targets.push({ symbol: key, name: value, label: key + ': ' + value })
        console.log(`${key}: ${value}`)
      }
      this.assetClasses.unshift({ label: 'Native Token (ADA)', symbol: 'ADA' })

      getServerHome().then(home => {
        console.warn('Got Server Home!', home)
        home.networks.map(n => { n.label = n.name })
        this.networks = home.networks
        this.network = home.networks[0]

        home.contacts.map(c => {
          c.label = c.name + ' ' + c.hash + ' ' + c.tags.join(',')
        })
        this.toAddressBook = home.contacts
      }).catch(e => { console.error(e); this.error = e })
    })
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
    notValid: function () {
      return this.toAddress === null || this.fromAddress === null || this.amount === null
    },
    deploy: function () {
      console.warn('deploy', this.tab)
      this.deployAtoB()
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
        setTimeout(this.processProcess, 1000)
      }).catch(e => {
        console.error('ATOB ERR', e)
        this.error = e
      })
    }
  },
  data () {
    return {
      allTags: tags,
      error: false,
      tags: ['rps'],
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
      assetClass: { label: 'Native Token (ADA)', symbol: 'ADA' },
      assetClasses: [],
      target: { label: 'CAD: Canadian Dollar', symbol: 'CAD', name: 'Canadian Dollar' },
      targets: [],
      taxUnit: 'CAD',
      output: 'Waiting to deploy...',
      contract: 'Waiting for contract...',
      process: false
    }
  }
}

</script>
