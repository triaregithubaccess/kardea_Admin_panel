<template lang="pug">
  section


      template( v-for="(one_row,index) in d_data")
        el-row(:span="24")
          template( v-for="(one_day,index2) in one_row")

            template( v-if="index == 0")

              el-col.sl( :span="1", v-if="index2 == 0")
                .sl.he( ) {{one_day}}
              el-col.sl.he( :span="3" v-if="index2 > 0" )
                .sl.he( ) {{one_day}}



            template( v-if="index > 0")

              el-col.sl( :span="1" v-if="index2 == 0") {{one_day}}
              el-col.slc( :span="3" v-else v-bind:class="'color_m'+one_day")
                span



</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  import echarts from '../views/charts/echarts.vue'
  //import NProgress from 'nprogress'
  import { getDashboardInfo } from '../api/api';
  export default {
    components:
      {
        echarts
      },
    props: ['d_data'],
    data() {
      return {
        kind: '',
        watch: {
          'd_data': function () {
            console.log("Watch Daly")
          }
        },
        data: [ ]

        }

    },
    methods: {

    },
    mounted() {
    }
  }

</script>

<style scoped>
  .text {
    font-size: 14px;
  }

  .item {
    padding: 5px 0;
  }

  .clearfix:before,
  .clearfix:after {
    display: table;
    content: "";
  }
  .clearfix:after {
    clear: both
  }

  /*.box-card {*/
    /*width: 480px;*/
  /*}*/
  .sl {
    height: 10px;
    margin: 2px;
    margin-top: 0;
    text-align: right;
    font-size: 10px;
  }
  .he {
    height: 10px;
    margin: 1px;
    text-align: center;
    font-size: 10px;
  }
  .slc {
    height: 10px;
    background: #f0f0f5;
    margin: 1px;
    text-align: center;
  }
  .color_m0 {

  }
  .color_m1 { background: #d9f2e6; }
  .color_m2 { background: #8cd9b3; }
  .color_m3 { background: #40bf80; }
  .color_m4 { background: #339966; }

</style>