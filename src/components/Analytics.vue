<template lang="pug">
  section
    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.name')
        el-form-item
          el-button(type='primary', v-on:click='getData') Search
        el-date-picker( v-model="period" ,
          type="daterange" ,
          align="right",
          placeholder="Pick a range",
          :picker-options="daly_picker_options")
        el-select.left5( v-model="table2" )
          el-option(v-for="item in a_options",
            :key="item.value" ,
            :label="item.label" ,
            :value="item.value")
        el-select.left5( v-model="languages")
          el-option(v-for="item in la_options",
          :key="item.value" ,
          :label="item.label" ,
          :value="item.value")

    el-table(v-model="articlesVisible", v-show="articlesVisible",:data='articles', highlight-current-row='',
        v-loading='listLoading',
        @selection-change='selsChange',
        @sort-change='sortChange',
        @expand="exp",
        style='width: 100%;')
      el-table-column(type='expand', width='55')
        template( scope="props")
          p
            b Abstract :
            |  {{ props.row.abstract }}
          p
            b Full Text :
            |  {{ props.row.full_text }}
          p
            b Source :
            |  {{ props.row.source }}
          p
            b Tags :
            |  {{ props.row.tags }}
          p

      el-table-column( prop='channel_name', label='Topic',  sortable='')
      el-table-column(prop='headline', label='Headline',  sortable='', width='310')
        template( scope="scope")
          .hs() {{scope.row.headline}}:
          .hs() {{scope.row.subtitle}}

      el-table-column(label='Picture', width='110')
        template( scope="scope")
          img(:src="scope.row.picture   + '?width=100&height=100'")
      el-table-column( prop='duration', label='Duration',  sortable='', align='center')
      el-table-column( prop='is_read', label='Read Count',  sortable='', align='center')
      el-table-column( prop='likes', label='Likes',  sortable='', align='center')
      el-table-column( prop='bookmarks', label='bookmark',  sortable='', align='center')
      el-table-column( prop='comments', label='comments',  sortable='', align='center')

    el-table(v-model="channelsVisible",v-show="channelsVisible", :data='channels', highlight-current-row='',
      v-loading='listLoading',
      @selection-change='selsChange',
      @sort-change='sortChange',
      style='width: 100%;')

      el-table-column(prop='title', label='Title',  sortable='')
      el-table-column(prop='reads_count', label='Reads',  sortable='', align='center')
      el-table-column(prop='reads_duration', label='Duration',  sortable='', align='center')
      el-table-column(prop='subscribers_count', label='Subscribers',  sortable='', align='center')
      el-table-column(prop='articles_count', label='Amount of news',  sortable='', align='center')

    el-table(v-model="tagsVisible",v-show="tagsVisible", :data='tags', highlight-current-row='',
      v-loading='listLoading',
      @selection-change='selsChange',
      @sort-change='sortChange',
      style='width: 100%;')

      el-table-column(prop='name', label='Name',  sortable='', width="211px")
      el-table-column(prop='articles', label='Articles',  sortable='', align='center', width="111px")

    el-col.toolbar(:span='24')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')




</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  import Vue from 'vue'

  import { getArticleForAnalyticsListPage, getChannelForAnalyticsListPage, getTagForAnalyticsListPage } from '../api/api';

  export default {
    watch: {
      'languages': function () {
        this.getData();
      },
      'period': function () {

        this.rep_start = this.period[0]
        var tmp_end = new Date(this.period[1]);
        tmp_end.setTime(tmp_end.getTime() + 3600 * 1000 * 24 );
        this.rep_end = tmp_end
        this.getData();
      },
      'table2': function () {
        this.articlesVisible = this.table2 == "Article";
        this.channelsVisible = this.table2 == "Channel";
        this.tagsVisible = this.table2 == "Tag";
        this.getData();
      }
    },

    components:
      {
      },
    data() {
      return {
        table2:'Article',
        articlesVisible: true,
        channelsVisible: false,
        tagsVisible: false,
        a_options: [{
          value: 'Article',
          label: 'Articles'
        }, {
          value: 'Channel',
          label: 'Topics'
        }, {
          value: 'Tag',
          label: 'Tags'
        } ],
        sort_obj: null,
        cur_news: '',
        rep_start: new Date(0),
        rep_end: new Date(),
        period: '',
        languages: 'de,en',
        la_options: [{
          value: 'de,en',
          label: 'Data for All'
        }, {
          value: 'de',
          label: 'Data for DE'
        }, {
          value: 'en',
          label: 'Data for EN'
        } ],

        langs:  [
          {
            value: 'de',
            label: 'DE'
          },
          {
            value: 'en',
            label: 'EN'
          },
        ],
        filters: {
          name: ''
        },
        articles: [],
        channels: [],
        tags: [],
        total: 0,
        page: 1,
        per_page_const:  10,
        listLoading: false,
        sels: [],//selected rows

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
      filterLang(value, row) {
        return row.language === value;
      },

      getData() {
        //console.log("Get Art!");
        let para2 = {
          page: this.page,
          pre: this.pre,
          per_page: this.per_page_const,
          name: this.filters.name,
          start: this.rep_start,
          stop: this.rep_end,
          language: this.languages
        };

        let sort_str = '_id';
        if (this.sort_obj != null){
          sort_str = this.sort_obj.prop;
          if (this.sort_obj.order != 'ascending'){
            sort_str = '-'+ sort_str;
          }
          para2["sort"] = sort_str
        }

        this.listLoading = true;

        let get_func;

        if (this.table2 == 'Article') { get_func = getArticleForAnalyticsListPage }
        if (this.table2 == 'Channel') { get_func = getChannelForAnalyticsListPage }
        if (this.table2 == 'Tag') { get_func = getTagForAnalyticsListPage }
        //console.log(para2)
        get_func(para2, this.$router.token).then((res) => {
          //console.log("respppppppp")
          this.total = res.data.count;
          if (this.table2 == 'Article') { this.articles = res.data.result }
          if (this.table2 == 'Channel') { this.channels = res.data.result }
          if (this.table2 == 'Tag') { this.tags = res.data.result }
          this.listLoading = false;
        }).catch((err) => {console.log("in catch ggg", err);} );
      },

      selsChange: function (sels) {
        this.sels = sels;
      },
      sortChange: function (obj) {
        this.sort_obj = obj
        this.getData();
      },
      exp(a,b){
        this.cur_news = a._id
      },
      handleCurrentChange(val) {
        //console.log("HCP");
        this.page = val;
        this.getData();
      },



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

  .mag{
    display: inline-block;
    margin: 0 0 0 7px;
    color: #087421 ;
  }
  .left5{
    padding: 0 0 0 10px;
  }
  /*.box-card {*/
    /*width: 480px;*/
  /*}*/

</style>