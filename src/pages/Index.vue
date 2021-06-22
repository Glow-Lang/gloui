<template>
<q-page class="flex flex-center">
  <div class="text-h3" style="width: 100%; text-align:center;">
    Welcome to Glow!
  </div>
  <ul class="text-h4">
    <li><router-link to="/Contacts">Contacts</router-link></li>
  </ul>
</q-page>

</template>

<script>
export default {
    name: 'PageIndex',
    mounted() {},
    data() {
        return {}
    }
}
</script>
