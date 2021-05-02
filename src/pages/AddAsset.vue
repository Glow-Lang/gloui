<template>
<div class="flex flex-center">
  <div class="q-pa-md q-gutter-sm" style="width:100%">
    <q-breadcrumbs>
      <q-breadcrumbs-el icon="home" to="/" />
      <q-breadcrumbs-el label="Add Asset" icon="build" class="text-h5"/>
    </q-breadcrumbs>
  </div>
  <asset  :value="asset" @input="asset = $event" style="min-width: 80vw" />

  <!-- {{ asset }} -->
</div>
</template>

<script>
import Asset from 'components/Asset.vue'
// alert('here')
export default {
  name: 'AddAsset',
  components: {  Asset },
  data() {
    return {
      asset: null
    }
  }

}
</script>
