<template lang="pug">
  section

    el-row(:span="24")
      template( v-for="(one_row,index) in data")

          template( v-for="(one_day,index2) in one_row")
            el-col( :span="3" , v-if="index == 0")
              .sl.he( ) {{one_day}}
            el-col( :span="3", v-else)
              .sl( v-if="index2 == 0") {{one_day}}
              .slc( v-else v-bind:class="'color_m'+one_day")
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
    data() {
      return {
        kind: '',
        data: [
          ["", "mn","th","we","th","fr","st", "sn"],
          ["00h",0,0,1,0,0,0,2],
          ["01h",0,0,1,0,1,0,2],
          ["02h",0,0,2,1,0,1,2],
          ["03h",0,0,0,1,0,0,0],
          ["04h",0,0,1,0,1,0,0],

          ["05h",0,0,1,0,0,0,2],
          ["06h",0,1,0,0,0,0,0],
          ["07h",0,0,1,1,0,0,2],
          ["08h",0,1,0,0,2,0,0],
          ["09h",0,0,1,0,0,0,2],

          ["10h",2,0,1,0,0,0,0],
          ["11h",0,0,1,0,0,0,2],
          ["12h",0,0,0,1,0,0,0],
          ["13h",1,0,1,0,0,0,0],
          ["14h",0,2,1,0,0,0,2],

            ["15h",0,0,1,0,0,0,0],
            ["16h",0,1,1,0,0,0,2],
            ["17h",1,0,1,0,0,0,0],
            ["18h",0,1,0,1,1,0,1],
            ["19h",0,0,1,0,0,0,2],

            ["20h",0,0,1,0,0,0,1],
            ["21h",0,0,0,0,0,0,0],
            ["22h",0,0,1,1,0,0,1],
            ["23h",0,0,1,0,0,0,2]

          ]
        }

    },
    methods: {
      hc : function (x) {
        console.log("x=",x)
        this.kind = x
      },
      getData: function() {
        getDashboardInfo({}, this.$router.token).then((res) => {
          console.log(res)
          this.total = res.data.result.total;

        }).catch((err) => {console.log("in catch get Dashboard Data", err);} );
      }

    },
    mounted() {
      this.getData();
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

  .box-card {
    width: 480px;
  }
  .sl {
    height: 10px;
    bac-kground: #d3dce6;
    padding: 2px;
    margin: 2px;
    text-align: right;

    font-size: 10px;
  }
  .he {
    height: 10px;

    padding: 2px;
    margin: 2px;
    text-align: center;

    font-size: 10px;
  }
  .slc {
    height: 10px;
    width: 86%;
    background: #d3dce6;
    padding: 2px;
    margin: 2px;
    text-align: center;
  }
  .color_m0 {

  }
  .color_m1 {
    background: #ffb457;
  }
  .color_m2 {
    background: #ff653a;
  }

</style>