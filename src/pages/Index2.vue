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
                  {{ addressBook }}
                  <p> Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
                  <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
                </q-tab-panel>

      <!--           <q-tab-panel name="rockpaperscissors"> -->
      <!--             <q-select -->
      <!--               filled -->
      <!--               v-model="fromAddress" -->
      <!--               :options="fromAddressBook" -->
      <!--               use-input -->
      <!--               hide-selected -->
      <!--               fill-input -->
      <!--               input-debounce="0" -->
      <!--               @filter="filterFrom" -->
      <!--               label="Player One Address" /> -->
      <!--             <q-select -->
      <!--   filled -->
      <!--   v-model="model" -->
      <!--   use-input -->
      <!--   hide-selected -->
      <!--   fill-input -->
      <!--   input-debounce="0" -->
      <!--   :options="options" -->
      <!--   @filter="filterFn" -->
      <!--   hint="Basic filtering" -->
      <!--   style="width: 250px; padding-bottom: 32px" -->
      <!-- > -->
      <!--   <template v-slot:no-option> -->
      <!--     <q-item> -->
      <!--       <q-item-section class="text-grey"> -->
      <!--         No results -->
      <!--       </q-item-section> -->
      <!--     </q-item> -->
      <!--   </template> -->
      <!-- </q-select> -->
      <!--             <br/> -->
      <!--             <q-select filled v-model="toAddress" :options="addressBook" label="Player Two Address" /> -->
      <!--             <br/> -->
      <!--             <q-select filled v-model="choice" :options="choices" label="Choice" /> -->
      <!--             <br/> -->
      <!--             <q-input filled v-model="wager" label="Wager" /> -->

      <!--           </q-tab-panel> -->

                <q-tab-panel name="movies">
                  <div class="text-h4 q-mb-md">Movies</div>
                  <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
                  <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
                  <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
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
import { ensureAddressBook, findAddressesByName, getFromAddressBook, filterBookUsingTags } from '../assets/addressBook.ss'
const blockchains = ['Cardano', 'Drewc', 'Moonlight', 'Trump']
const fromAddressBook = getFromAddressBook('Private Key')

const toAddresses =
      [
        '0xbc1qedg2n3mqsgxrrff2xdn3wxqwy6f8434xkz45v9',
        '0x18VwoRVyjTYoH4TCvxkkQxbk5WLMZa6eTN',
        '0x3J1j74SGjcbX6bVXqtZDrKy8p9P8i9AGR4'
      ]
const choices = ['Rock', 'Paper', 'Scissors']

const depAddresses =
      [
        '0xbc1qedg2n3mqsgxrrff2xdn3wxqwy6f8434xkz45v9',
        '0x18VwoRVyjTYoH4TCvxkkQxbk5WLMZa6eTN',
        '0x3J1j74SGjcbX6bVXqtZDrKy8p9P8i9AGR4'
      ]

const stringOptions = [
  'Google', 'Facebook', 'Twitter', 'Apple', 'Oracle'
]

const tags = ['rps', 'whodo', 'unamed one', 'moonshine', 'crazy', 'kitty cats']

function filterAddressesProc (prop, valProp, book) {
  return function (val, update, abort) {
    update(() => {
      const prevVal = this[valProp]
      const prevBook = this[prop]
      if (val.startsWith(prevVal)) {
        this[prop] = findAddressesByName(val, prevBook)
      } else {
        this[prop] = findAddressesByName(val, book)
      }
    })
  }
}

export default {
  name: 'PageIndex',
  computed: {
    // a computed getter
    addressBook: function () { return ensureAddressBook() },
    fromAddressBook: {
      get: function () {
        const fab = filterBookUsingTags(this.fromAddressList, this.tags)
        return fab;
      },
      set: function (v) { this.fromAddressList = v }
    }
  },
  methods: {
    filterFrom: filterAddressesProc('fromAddressBook'),
    filterFn (val, update, abort) {
      update(() => {
        const needle = val.toLowerCase()
        this.options = stringOptions.filter(v => v.toLowerCase().indexOf(needle) > -1)
      })
    },
    findAddressesByName

  },
  data () {
    return {
      model: null,
      options: stringOptions,
      allTags: tags,
      tags: ['rps'],
      tab: 'rockpaperscissors',
      depTab: 'deploy',
      splitterModel: 20,
      chainModel: 60,
      blockchain: blockchains[0],
      blockchains: blockchains,
      fromAddress: null,
      fromAddressList: fromAddressBook,
      toAddress: null,
      toAddresses,
      depAddresses,
      depAddress: null,
      choice: null,
      choices,
      wager: null
    }
  }
}

</script>
