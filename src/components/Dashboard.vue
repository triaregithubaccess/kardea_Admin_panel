<template lang="pug">
  section
    el-card( class="box-card")
      div( slot="header" class="clearfix")
        el-row(:span="24" )
          el-col( :span="7")
            span( style="line-hei-ght: 6px;") Total Info {{kind}}
          el-col( :span="15" , style="height:40px;")
            echarts
      el-row(:span="24")
        el-col( :span="11")
          .text.item(@click="hc('use')") Users {{total.users}}
          .text.item(@click="hc('poo')") Users allowed pushes {{total.allowed_pushes}}
          .text.item Topics {{total.channels}}
          .text.item Articles {{total.articles}}
        el-col( :span="11")
          .text.item Comments {{total.comments}}
          .text.item Bookmarks {{total.bookmarks}}
          .text.item Likes {{total.likes}}
          .text.item Read Articles {{total.read_news}}
    el-row(:span="24")
      el-col( :span="11")
        daly()

</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  import echarts from '../views/charts/echarts.vue'
  import daly from '../components/Daly.vue'
  //import NProgress from 'nprogress'
  import { getDashboardInfo } from '../api/api';
  export default {
    components:
      {
        echarts,
        daly
      },
    data() {
      return {
        kind: '',
        total:{
          users: 0,
          allowed_pushes: 0,
          channels: 0,
          articles: 0,
          comments: 0,
          bookmarks: 0,
          likes: 0,
          read_news: 0,
        }
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

</style>