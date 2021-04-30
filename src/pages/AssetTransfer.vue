<template>
  <div class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%; text-align: center;">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el label="Transfer Assets" icon="payments" class="text-h5"/>
    </q-breadcrumbs>
    </div>
<transfer-asset />
</div>
</template>

<script>
import TransferAsset from 'components/TransferAsset.vue'
export default {
  name: 'AssetTransfer',
  components: { TransferAsset }
}
</script>
