<template>
  <div class="flex flex-center">
    <div class="q-pa-md q-gutter-sm" style="width:100%; text-align: center;">
      <q-breadcrumbs>
        <q-breadcrumbs-el icon="home" to="/" />
        <q-breadcrumbs-el label="Glow REPL" icon="payments" class="text-h5"/>
    </q-breadcrumbs>
    </div>
      <gerbil-repl />
</div>
</template>

<script>
import GerbilRepl from 'components/GerbilREPL.vue'
export default {
  name: 'GerbilREPL',
  components: { GerbilRepl }
}
</script>
