<template lang="pug">
  div
    h1  vuex  test
    | Clicked : {{ getCount }} times
    button(@click='increment') +
    button(@click='decrement') -

</template>

<script>
  import { mapGetters } from 'vuex'
  import { mapActions } from 'vuex'

  export default {
    computed: {
  	// 使用对象展开运算符将 getters 混入 computed 对象中
    ...mapGetters([
      'getCount'
      // ...
    ])
    },
    methods: {
    ...mapActions([
      'increment', // 映射 this.increment() 为 this.$store.dispatch('increment')
      'decrement'
    ])
      //...mapActions({
      //  add: 'increment' // 映射 this.add() 为 this.$store.dispatch('increment')
      //})
    }
  }

</script>