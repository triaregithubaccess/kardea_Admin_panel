<template  lang="pug">
    section( class="chart-container", float="right")
      el-row( )
        el-col( :span="22", v-bind:class="'col-'+gtype"  )
          div(  v-bind:class="'ch_'+gtype", style="width:100%; height:100%;")
</template>

<script>
    import echarts from 'echarts'

    export default {
        props: ['gdata','pdata', 'gname', 'gtype'],

        data() {
            return {
              ina:0,
              new_u:0,
                chartLine: null,
                chartPie: null
            }
        },
        watch: {
          'gdata': function () {
            this.chartLine.setOption({
              series: [
                {
                  name: this.gname,
                  type: 'line',
                  stack: 'sta1',
                  data: this.gdata,
                }
              ]
            })
          } ,
          'pdata': function () {
              this.chartLine.setOption({
                series: [
                  {data: this.pdata}
                ]

              })
          }
        },
        methods: {

        },
        mounted: function () {
          var _this = this;

          if (this.gtype == 'line') {
            this.chartLine = echarts.init(document.getElementsByClassName('ch_line')[0]);
            this.chartLine.setOption({
              title: {
                show: false
//                    text: 'Line Chart'
              },
              tooltip: {
                trigger: 'axis',
                position: [-20, 40]
              },
              legend: {
                data: ['one', 'two', 'three']
              },
              grid: {
                top: 5,
//                    left: '3%',
//                    right: '4%',
//                    bottom: '3%',
                containLabel: false
              },
              xAxis: {
                type: 'category',
                boundaryGap: false,
                data: ['1y', '6m', '1m', '1w', '2d', 'today']
              },
              yAxis: {
                show: false,
                type: 'value'
              },
              series: [
                {
                  name: 'name1',
                  type: 'line',
                  stack: 'sta1',
                  data: _this.gdata,
                }
              ]
            });

          }
          if (this.gtype == 'pie') {
            this.chartLine = echarts.init(document.getElementsByClassName('ch_pie')[0]);
            this.chartLine.setOption({

                 color: [
                   '#259567',
                   '#e51333',
                   '#ece42d',
                   '#91c7ae','#749f83',  '#ca8622', '#bda29a','#6e7074', '#546570', '#c4ccd3'],

                title: {
                    text: 'Active-Inactive-New Users',
//                    subtext: 'sub text',
                    x: 'center'
                },
                tooltip: {
                    trigger: 'item',
                    formatter: "{a} <br/>{b} : {c} ({d}%)"
                },
//                legend: {
//                    orient: 'vertical',
//                    left: 'left',
//                    data: ['all', 'inactive', 'new']
//                },
                series: [
                    {
                        name: 'users',
                        type: 'pie',
                        radius: '55%',
                        center: ['50%', '50%'],
                        data: this.pdata,
                        itemStyle: {
                            emphasis: {
                                shadowBlur: 10,
                                shadowOffsetX: 0,
                                shadowColor: 'rgba(0, 0, 0, 0.5)'
                            }
                        }
                    }
                ]
            });

          }


        }

    }

</script>

<style scoped>
    .chart-container {
        width: 100%;
        float: right;
    }
    .col-pie {
      height:207px;
    }
    .col-line {
      height:150px;
    }

    /*.chart div {
        height: 400px;
        float: left;
    }*/

    .el-col {
        padding: 0px 0px;
    }
</style>