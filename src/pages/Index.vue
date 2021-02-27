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
          <q-tab name="rockpaperscissors"  label="Rock-Paper-Scissors" no-caps />
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

                <q-tab-panel name="rockpaperscissors">
                  <q-select
                    filled
                    v-model="fromAddress"
                    :options="fromAddressBook"
                    use-input
                    use-chips
                    input-debounce="0"
                    @filter="filterFrom"
                    label="From: Address" />

                  <br/>
                  <q-select
                    label="To: Address"
                    filled v-model="toAddress"
                    :options="toAddressBook"
                    use-input
                    use-chips
                    new-value-mode="add"

                    input-debounce="0"
                    @filter="filterTo"
                    />
                  <!-- <br/> -->
                  <!-- <q-select filled v-model="choice" :options="choices" label="Choice" /> -->
                  <br/>

                  <q-select
                    filled v-model="amount" label="Amount" :options="amountOptions"
                    use-input
                    use-chips
                    new-value-mode="add"
                    class="inline-block"
                    />
                  <q-select filled v-model="assetClass" :options="assetClasses" label="Asset"
                            class="inline-block"/>

                  <span v-if="amount" class="text-h5 text-primary float-right">
                    ${{exchangeValue}} {{taxUnit}} </span>

                  <div v-if="amount" class="text-weight-light text-h6">
                    <ul>
                      <li><label> Fees: </label> {{feesAndTotals.fee}}</li>
                      <li><label> Total: </label> {{feesAndTotals.total}} {{assetClass}} </li>
                    </ul>
                  </div>
                </q-tab-panel>

                <q-tab-panel name="movies">
                  <div class="text-h4 q-mb-md">Movies</div>
                </q-tab-panel>
              </q-tab-panels>
              <hr/>

              <div class="text-h4 text-center">Contract</div>
              <pre><code>
              </code></pre>
            </div>
          </template>

          <template v-slot:after>
            <div class="bg-blue-grey-1 text-center" style="height: 100%">
              <br/>
              <q-select filled style="width:92%; margin: auto" v-model="blockchain" :options="blockchains" label="Blockchain" />
              <br/>
              <q-btn color="white" text-color="black" label="Compile" style="width:92%"/>
              <br/>
              <q-tabs
                v-model="depTab"
                dense
                class="text-grey"
                shrink
                active-color="primary"
                indicator-color="primary"
                align="justify"
                narrow-indicator
                style="padding-top: 1em"
                >
                <q-tab name="validate" label="Validate" />
                <q-tab name="download" label="Download" />
                <q-tab name="deploy" label="Deploy" />
              </q-tabs>

              <q-separator />

              <q-tab-panels v-model="depTab" animated class="bg-blue-grey-1 text-center">
                <q-tab-panel name="validate">
                  Lorem ipsum dolor sit amet consectetur adipisicing elit.
                </q-tab-panel>

                <q-tab-panel name="download">
                  <div class="text-h6">Alarms</div>
                  Lorem ipsum dolor sit amet consectetur adipisicing elit.
                </q-tab-panel>

                <q-tab-panel name="deploy" class="text-center">
                  <q-select filled v-model="depAddress"
                            :options="depAddresses"
                            label="Address"
                            style="width:92%; margin: auto"/>
                  <br>
                  <q-btn color="white" text-color="black" label="Deploy" style="width:92%"/>
                </q-tab-panel>
              </q-tab-panels>
              </div>
          </template>

        </q-splitter>
      </template>

    <br>
    </q-splitter>
    <hr/>
  </div>
</q-page>
</template>

<script>
import {
  findAddressesByName,
  getFromAddressBook,
  filterBookUsingTags,
  getToAddressBook,
  feesAndTotals
} from '../assets/addressBook.ss'
const blockchains = ['Cardano', 'Drewc', 'Moonlight', 'Trump']
const theFromAddressBook = getFromAddressBook('Private Key')
const theToAddressBook = getToAddressBook()

const choices = ['Rock', 'Paper', 'Scissors']

const depAddresses =
      [
        '0xbc1qedg2n3mqsgxrrff2xdn3wxqwy6f8434xkz45v9',
        '0x18VwoRVyjTYoH4TCvxkkQxbk5WLMZa6eTN',
        '0x3J1j74SGjcbX6bVXqtZDrKy8p9P8i9AGR4'
      ]

const tags = ['rps', 'whodo', 'unamed one', 'moonshine', 'crazy', 'kitty cats']

function filterAddressesProc (prop, book) {
  return function (val, update, abort) {
    update(() => {
      this[prop] = findAddressesByName(val, filterBookUsingTags(book, this.tags))
    })
  }
}

const assetClasses = ['Native Token', 'FooDollBar', 'BTC', 'DREW$']
const amountOptions = ['All at From: Address']

export default {
  name: 'PageIndex',
  computed: {
    // a computed getter
    fromAddressBook: {
      get: function () {
        const fab = filterBookUsingTags(this.fromAddressList, this.tags)
        return fab
      },
      set: function (v) { this.fromAddressList = v }
    },
    toAddressBook: {
      get: function () {
        const fab = filterBookUsingTags(this.toAddressList, this.tags)
        return fab
      },
      set: function (v) { this.toAddressList = v }
    },
    exchangeValue: function () {
      return this.amount * 3.14159
    },

    feesAndTotals: function () { return feesAndTotals(this.amount, this.assetClass, this.blockchain) }

  },
  methods: {
    filterFrom: filterAddressesProc('fromAddressBook', theFromAddressBook),
    filterTo: filterAddressesProc('toAddressBook', theToAddressBook),
    findAddressesByName
  },
  data () {
    return {
      allTags: tags,
      tags: ['rps'],
      tab: 'rockpaperscissors',
      depTab: 'deploy',
      splitterModel: 20,
      chainModel: 60,
      blockchain: blockchains[0],
      blockchains: blockchains,
      fromAddress: null,
      fromAddressList: theFromAddressBook,
      toAddress: null,
      toAddressList: theToAddressBook,
      depAddresses,
      depAddress: null,
      choice: null,
      choices,
      amount: null,
      amountOptions: amountOptions,
      assetClass: 'Native Token',
      assetClasses: assetClasses,
      taxUnit: 'CAD'
    }
  }
}

</script>
