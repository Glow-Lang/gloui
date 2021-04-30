<template>
  <q-list v-if="value">
    <q-item>
      <q-item-section side top>
        <q-item-label caption>type</q-item-label>
        <q-badge color="teal" v-if="value.type"
                 v-bind:label="value.type.name" />
        <q-item-label caption>&nbsp;net</q-item-label>
        <q-badge color="teal" v-bind:label="value.network" />
        </q-item-section>

      <q-item-section>
        <span v-if="value.name"> {{ value.name }} </span>
        <span v-if="value.description"> {{ value.description }} </span>
        <q-list dense v-if="value.type">
          <q-item dense>
            path: {{ value.path }}
          </q-item>
          <q-item
                  v-for="(val, key) in value.type.description"
                  v-bind:key="key"
                  dense>
           {{ key }}:&nbsp;{{ val }}
          </q-item>
        </q-list>
      </q-item-section>
    </q-item>
  </q-list>
</template>

<script>
export default {
name: "ResourceItem",
props: [ 'value' ]
}
</script>
