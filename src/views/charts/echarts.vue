<template>
    <section class="chart-container" float="right">
        <el-row>
            <el-col :span="22" sty-le="width:200px; height:120px;">

                <div id="chartLine" style="width:100%; height:100%;"></div>

            </el-col>

        </el-row>
    </section>
</template>

<script>
    import echarts from 'echarts'

    export default {
        props: ['gdata', 'gname'],
//        props: {
//          gdata: {
//            default() {  return []; }
//          }
//        },

        data() {
            return {
                chartColumn: null,
                chartBar: null,
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
          }
        },
        mounted: function () {
            var _this = this;

//            this.chartColumn = echarts.init(document.getElementById('chartColumn'));
//            this.chartBar = echarts.init(document.getElementById('chartBar'));
            this.chartLine = echarts.init(document.getElementById('chartLine'));
//            this.chartPie = echarts.init(document.getElementById('chartPie'));

//            this.chartColumn.setOption({
//                title: { text: 'Column Chart' },
//                tooltip: {},
//                xAxis: {
//                    data: ["One", "two", "Tree", "Four", "Five", "Six"]
//                },
//                yAxis: {},
//                series: [{
//                    name: 'Trend',
//                    type: 'bar',
//                    data: [5, 20, 36, 10, 10, 20]
//                }]
//            });

//            this.chartBar.setOption({
//                title: {
//                    text: 'Bar Chart',
//                    subtext: '数据来自网络'
//                },
//                tooltip: {
//                    trigger: 'axis',
//                    axisPointer: {
//                        type: 'shadow'
//                    }
//                },
//                legend: {
//                    data: ['2011', '2012']
//                },
//                grid: {
//                    left: '3%',
//                    right: '4%',
//                    bottom: '3%',
//                    containLabel: true
//                },
//                xAxis: {
//                    type: 'value',
//                    boundaryGap: [0, 0.01]
//                },
//                yAxis: {
//                    type: 'category',
//                    data: ['y1', 'y2', 'y3', 'yy4', 'yy5', 'maxmax']
//                },
//                series: [
//                    {
//                        name: '2011',
//                        type: 'bar',
//                        data: [18203, 23489, 29034, 104970, 131744, 630230]
//                    },
//                    {
//                        name: '2012',
//                        type: 'bar',
//                        data: [19325, 23438, 31000, 121594, 134141, 681807]
//                    }
//                ]
//            });

            this.chartLine.setOption({
                title: {
                  show: false
//                    text: 'Line Chart'
                },
                tooltip: {
                    trigger: 'axis',
                  position: [-20, 10]
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
                        data: _this.gdata, //[120, 132, 101, 134, 90, 230, 210]
                    }
                ]
            });

//            this.chartLine.setOption({
//                title: {
//                    text: 'Line Chart'
//                },
//                tooltip: {
//                    trigger: 'axis'
//                },
//                legend: {
//                    data: ['one', 'two', 'three']
//                },
//                grid: {
//                    left: '3%',
//                    right: '4%',
//                    bottom: '3%',
//                    containLabel: true
//                },
//                xAxis: {
//                    type: 'category',
//                    boundaryGap: false,
//                    data: ['y1', 'y2', 'y3', 'yy4', 'yy5', 'maxmax']
//                },
//                yAxis: {
//                    type: 'value'
//                },
//                series: [
//                    {
//                        name: 'name1',
//                        type: 'line',
//                        stack: 'sta1',
//                        data: [120, 132, 101, 134, 90, 230, 210]
//                    },
//                    {
//                        name: 'name12',
//                        type: 'line',
//                        stack: 'sta1',
//                        data: [220, 182, 191, 234, 290, 330, 310]
//                    },
//                    {
//                        name: 'name13',
//                        type: 'line',
//                        stack: 'sta13',
//                        data: [820, 932, 901, 934, 1290, 1330, 1320]
//                    }
//                ]
//            });
//
//            this.chartPie.setOption({
//                title: {
//                    text: 'Pie Chart',
//                    subtext: '纯属虚构',
//                    x: 'center'
//                },
//                tooltip: {
//                    trigger: 'item',
//                    formatter: "{a} <br/>{b} : {c} ({d}%)"
//                },
//                legend: {
//                    orient: 'vertical',
//                    left: 'left',
//                    data: ['直接访问', '邮件营销', '联盟广告', '视频广告', '搜索引擎']
//                },
//                series: [
//                    {
//                        name: '访问来源',
//                        type: 'pie',
//                        radius: '55%',
//                        center: ['50%', '60%'],
//                        data: [
//                            { value: 335, name: '直接访问' },
//                            { value: 310, name: '邮件营销' },
//                            { value: 234, name: '联盟广告' },
//                            { value: 135, name: '视频广告' },
//                            { value: 1548, name: '搜索引擎' }
//                        ],
//                        itemStyle: {
//                            emphasis: {
//                                shadowBlur: 10,
//                                shadowOffsetX: 0,
//                                shadowColor: 'rgba(0, 0, 0, 0.5)'
//                            }
//                        }
//                    }
//                ]
//            });
        }

    }

</script>

<style scoped>
    .chart-container {
        width: 100%;
        float: right;
    }
    /*.chart div {
        height: 400px;
        float: left;
    }*/

    .el-col {
        padding: 0px 0px;
    }
</style>