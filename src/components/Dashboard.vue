<template lang="pug">
  section
    .toolbar
    el-row( )
      el-col( :span="9")
        el-card( class="box-card")
          div( slot="header" class="clearfix")
            el-row(:span="24" )
              el-col( :span="7")
                span( ) Total Info {{kind}}
              el-col( :span="15" , style="height:115px;" )
                echarts(:gdata="g_data", :gname="kind", gtype="line")
          el-row(:span="24")
            el-col( :span="11")
              .text.item(@click="hc('users')") Users
                span.mag {{total.users}}
              .text.item(@click="hc('users_push')") Users allowed pushes
                span.mag {{total.allowed_pushes}}
              .text.item(@click="hc('topics')") Topics
                span.mag {{total.channels}}
              .span
              .text.item(@click="hc('news')") Articles
                span.mag {{total.articles}}
            el-col( :span="11")
              .text.item(@click="hc('comments')") Comments
                span.mag {{total.comments}}
              .text.item(@click="hc('bookmarks')") Bookmarks
                span.mag {{total.bookmarks}}
              .span
              .text.item(@click="hc('likes')") Likes
                span.mag {{total.likes}}
              .span
              .text.item(@click="hc('read')") Read Articles
                span.mag {{total.read_news}}
          el-row(:span="24")
          el-row(:span="24")
      el-col( :span="10")
        el-card( class="box-card")

          el-col(  )
            echarts(:pdata="p_data", gtype="pie")
          el-row()
            el-col()
              label() Inactive - users, that didn't use app for last
                input.days(v-model="ina", @change="handle_inactive()")
                | days
              .oo
              label() New - users, that have been registered for last
                input.days(v-model="new_u", @change="handle_inactive()")
                | days
          el-row()

    el-row( )
      el-col( :span="19")
        el-card( class="box-card")

          el-row
            el-col( :span="10", :offset="8")
              el-date-picker( v-model="daly_period" ,
                type="daterange" ,
                align="right",
                placeholder="Pick a range",
                :picker-options="daly_picker_options")
          el-row(:span="18",style="margin-top:10px;")
            el-col( :span="9", :offset="1")
              daly(:d_data="daly_data", :d_max="daly_max")
            el-col( :span="12", :offset="2")
              el-row
                el-col
                  el-card.pad5( class="box-card")
                    el-table(:data="os_data",border, :default-sort="def_sort", :highlight-current-row="false")
                      el-table-column(label="OS name")
                        template( scope="scope")
                          el-icon( name="os_name")
                          span {{ scope.row.os_name }}
                      el-table-column(label="Users", prop="value", align="center")
                      el-table-column(label="%", prop="proc", align="center", :formatter="proc_formatter")
              el-row
                el-col
                  el-card.pad5( class="box-card")
                    el-table(:data="countries_data",border, :default-sort="def_sort", :highlight-current-row="false")
                      el-table-column(label="Country", prop="country", width="200")
                      el-table-column(label="Users", prop="value", align="center")
                      el-table-column(label="%", prop="proc", align="center", :formatter="proc_formatter")


    el-row()


</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  import Vue from 'vue'
  import echarts from '../views/charts/echarts.vue'
  import daly from '../components/Daly.vue'
  //import NProgress from 'nprogress'
  import { getDashboardInfo, getDashboardGraphInfo, getDashboardDalyInfo, getDashboardPieInfo, getDashboardDemographInfo } from '../api/api';
  export default {
    components:
      {
        echarts,
        daly
      },
    watch: {
      'daly_period': function () {

        this.daly_begin = this.daly_period[0]
        var tmp_daly_end = new Date(this.daly_period[1]);
        tmp_daly_end.setTime(tmp_daly_end.getTime() + 3600 * 1000 * 24 );
        this.daly_end = tmp_daly_end
        console.log("watch daly period", this.daly_begin, this.daly_end)
        this.getDalyData();
        this.getDemoGraphData();
      }
    },
    data() {
      return {
        g_data: [] ,
        p_data: [] ,
        def_sort: {prop:"proc", order: "descending"},
        countries_data:[ ],
        os_data: [ ],
        ina: 7,
        new_u:7,
        daly_data: [] ,
        daly_max: 0,
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
            }, {
              text: 'From Start',
              onClick(picker) {
                const end = new Date();
                const start = new Date('2017-04-01');
                //start.setTime(start.getTime() - 3600 * 1000 * 24 * 2222);
                picker.$emit('pick', [start, end]);
              }
            }]   }
      }
    },
    methods: {
      proc_formatter: function (row, col) {
        var str = ""+row.proc+""
        var i = str.indexOf('.')
        if (i<0) {i = str.length}
        str = str.substr(0,i+3)
        return str
      },
      handle_inactive: function () {
        console.log('upd inactive')
        this.getPieData();
      },
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
      getPieData: function() {
        getDashboardPieInfo({not_active_days: this.ina, new_user_days: this.new_u}, this.$router.token).then((res) => {
          console.log("for Graph=", res, res.data.result)
          this.p_data = res.data.result;

        }).catch((err) => {console.log("in catch get Dashboard Pie Data", err);} );
      },
      getDalyData: function() {
        getDashboardDalyInfo({start: this.daly_begin, stop: this.daly_end}, this.$router.token).then((res) => {
          console.log("for daly=",  res, res.data.result)
          this.daly_data = res.data.result.data;
          this.daly_max = res.data.result.max;

        }).catch((err) => {console.log("in catch get Dashboard Daly Data", err);} );
      },
      getDemoGraphData: function() {
        getDashboardDemographInfo({start: this.daly_begin, stop: this.daly_end}, this.$router.token).then((res) => {
          console.log("for daly=",  res, res.data.result)
          this.countries_data = res.data.result.countries;
          this.os_data = res.data.result.os_names;

        }).catch((err) => {console.log("in catch get Dashboard Demograph Data", err);} );
      }

    },
    mounted() {
      this.getData();
      this.getGrData();
      this.getPieData();
      this.getDalyData();
      this.getDemoGraphData();
    }
  }

</script>

<style scoped>
  .text {
    display: inline-block;
    font-size: 14px;
    cursor: pointer;
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

  .mag{
    display: inline-block;
    margin: 0 0 0 7px;
    color: #087421 ;
  }
  .days{
    width:20px;
    text-align:center;
    margin: 3px;
  }
  .pad5{

    margin-top: 10px;
  }

</style>