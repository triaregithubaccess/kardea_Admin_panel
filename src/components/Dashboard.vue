<template lang="pug">
  section
    .toolbar
    el-row( )
      el-col( :span="9")
        el-card( class="box-card")
          div( slot="header" class="clearfix")
            el-row(:span="24" )
              el-col( :span="7")
                span( style="line-hei-ght: 6px;") Total Info {{kind}}
              el-col( :span="15" , style="height:45px;" )
                echarts(:gdata="g_data", :gname="kind")
          el-row(:span="24")
            el-col( :span="11")
              .text.item(@click="hc('users')") Users {{total.users}}
              .text.item(@click="hc('users_push')") Users allowed pushes {{total.allowed_pushes}}
              .text.item(@click="hc('topics')") Topics {{total.channels}}
              .text.item(@click="hc('news')") Articles {{total.articles}}
            el-col( :span="11")
              .text.item(@click="hc('comments')") Comments {{total.comments}}
              .text.item(@click="hc('bookmarks')") Bookmarks {{total.bookmarks}}
              .text.item(@click="hc('likes')") Likes {{total.likes}}
              .text.item(@click="hc('read')") Read Articles {{total.read_news}}
    el-row( )
      el-col( :span="9")
        el-card( class="box-card")
          el-row( )
            el-col( :span="12", :offset="6")
              el-date-picker( v-model="daly_period" ,
                type="daterange" ,
                align="right",
                placeholder="Pick a range",
                :picker-options="daly_picker_options")
            el-col( )
              daly(:d_data="daly_data")
          el-row( )


</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  import Vue from 'vue'
  import echarts from '../views/charts/echarts.vue'
  import daly from '../components/Daly.vue'
  //import NProgress from 'nprogress'
  import { getDashboardInfo, getDashboardGraphInfo, getDashboardDalyInfo } from '../api/api';
  export default {
    components:
      {
        echarts,
        daly
      },
    watch: {
      'daly_period': function () {
        console.log("watch daly period", this.daly_period[0])
        this.daly_begin = this.daly_period[0]
        this.daly_end = this.daly_period[1]
        this.getDalyData();
      }
    },
    data() {
      return {
        g_data: [] ,
        daly_data: [] ,
        kind: 'users',
        daly_period:{},
        daly_begin: new Date(0),
        daly_end: new Date(),
        total:{
          users: 0,
          allowed_pushes: 0,
          channels: 0,
          articles: 0,
          comments: 0,
          bookmarks: 0,
          likes: 0,
          read_news: 0,
        },
        daly_picker_options: {
          shortcuts: [{
              text: 'Last week',
              onClick(picker) {
                const end = new Date();
                const start = new Date();
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 7);
                picker.$emit('pick', [start, end]);
              }
            }, {
              text: 'Last month',
              onClick(picker) {
                const end = new Date();
                const start = new Date();
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 30);
                picker.$emit('pick', [start, end]);
              }
            }, {
              text: 'Last 3 months',
              onClick(picker) {
                const end = new Date();
                const start = new Date();
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 90);
                picker.$emit('pick', [start, end]);
              }
            }]   }
      }
    },
    methods: {
      hc : function (x) {
        console.log("x=",x)
        this.kind = x
        this.getGrData();
      },
      getData: function() {
        getDashboardInfo({}, this.$router.token).then((res) => {
          console.log(res)
          this.total = res.data.result.total;

        }).catch((err) => {console.log("in catch get Dashboard Data", err);} );
      },
      getGrData: function() {
        getDashboardGraphInfo({who: this.kind}, this.$router.token).then((res) => {
          console.log("for Graph=", res, res.data.result)
          this.g_data = res.data.result;

        }).catch((err) => {console.log("in catch get Dashboard Data", err);} );
      },
      getDalyData: function() {
        getDashboardDalyInfo({start: this.daly_begin, stop: this.daly_end}, this.$router.token).then((res) => {
          console.log("for daly=",  res, res.data.result)
          this.daly_data = res.data.result;

        }).catch((err) => {console.log("in catch get Dashboard Daly Data", err);} );
      }

    },
    mounted() {
      this.getData();
      this.getGrData();
      this.getDalyData();
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

</style>