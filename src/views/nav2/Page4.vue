<template lang="pug">
  div
    h1  vuex  test
    | Clicked : {{ getCount }} times
    button(@click='increment') +
    button(@click='decrement') -

</template>

<script lang="coffee">

  {mapGetters, mapActions} = require 'vuex'

  ggg = mapGetters ['getCount', 'getCountTwice']
  ggg.new_pr = -> 7 # if need additional props else just computed: mapGetters [<list getters>]

  module.exports =
    computed: ggg
    methods: mapActions ['increment', 'decrement']

</script>