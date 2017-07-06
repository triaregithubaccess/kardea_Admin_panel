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

      el-row(:span="24", style=" margin-top: 10px;margin-left: 20px;")
        el-col.slc.color_m4.legendd( :span="6", :offset="1")
        el-col.slc.color_m3.legendd( :span="6" )
        el-col.slc.color_m2.legendd( :span="6" )
        el-col.slc.color_m1.legendd( :span="6" )
      el-row(:span="24", style="margin-left: 20px;")
        el-col.sll.legendd( :span="6", :offset="1") 0
        el-col.sll.legendd( :span="6" )
        el-col.sll.legendd( :span="6" )
        el-col.sllr.legendd( :span="6" ) {{d_max}}


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
    props: ['d_data','d_max'],
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
    margin-bottom: 2px;
    margin-right: 6px;
    text-align: right;
    font-size: 10px;
  }
  .he {
    height: 10px;
    margin: 1px;
    text-align: center;
    font-size: 10px;
  }
  .legendd{
   width: 71px;
  }
  .slc {
    height: 10px;
    background: #F0F0F5;
    margin: 1px;
    text-align: center;
  }
  .sll {
    height: 10px;
    background: white;
    margin: 1px;
    text-align: left;
    font-size: 10px;
  }
  .sllr {
    height: 10px;
    background: white;
    margin: 1px;
    text-align: right;
    font-size: 10px;
  }

  .color_m1 { background: #43A486; }
  .color_m2 { background: #72BBA5; }
  .color_m3 { background: #9FD1C1; }
  .color_m4 { background: #D0E8E1; }

</style>