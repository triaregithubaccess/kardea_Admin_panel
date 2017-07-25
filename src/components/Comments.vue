<template lang="pug">
  section
    | {{show_id}}
    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.text', placeholder='words')
        el-form-item
          el-button(type='primary', v-on:click='getComments') Search

    el-table(:data='comments', highlight-current-row='',
        v-loading='listLoading',
        @selection-change='selsChange',
        @sort-change='sortChange',

        style='width: 100%;')
      el-table-column(type='expand', width='55')
        template( scope="props")
          p
            b Article :
            article_list(:che_id='props.row._id')

      el-table-column(label='Avatar', width='150' )
        template( scope="scope")
          img(:src="scope.row.user_avatar   + '?width=50&height=50'")
      el-table-column(prop='user_name', label='user Name', width='150', sortable='')

      el-table-column(prop='text', label='Comment',  sortable='')

      el-table-column(prop='created_at', label='Created at', width='200', sortable='', :formatter='formatDate')
      el-table-column(label='Edit', width='150')
        template(scope='scope')
          el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
          el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :current-page='page',:total='total', style='float:right;')
    // Edit
    el-dialog(:title="'Edit '+cur_user+'s comment'", v-model='editFormVisible', :close-on-click-modal='false')
      el-form(:model='editForm', label-width='80px',  ref='editForm')

        el-form-item(label='Comment', prop='text')
          el-input(v-model='editForm.text', auto-complete='off')


      .dialog-footer(slot='footer')
        el-button(@click.native='cancelEdit') Cancel
        el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
    // Create Interface
    el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
      el-form(:model='addForm', label-width='80px',  ref='addForm')

        el-form-item(label='Comment', prop='text')
          el-input(v-model='addForm.headline', auto-complete='off')

      .dialog-footer(slot='footer')
        el-button(@click.native='addFormVisible = false') Cancel
        el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  //import NProgress from 'nprogress'
  import { getCommentListPage,getChannelListPage, getArticlesCommentListPage, removeComment, editComment, addComment } from '../api/api';
  export default {
    props: ['news_id','show_id'],
    components:
      {

      },
    data() {
      return {

        sort_obj: null,

        filters: {
          text: ''
        },
        cur_user : '',
        comments: [],
        total: 0,
        page: 2,
        per_page_const: 4,
        listLoading: false,
        sels: [],//selected rows

        editFormVisible: false,
        editLoading: false,

        // Edit
        editForm: {
          text: ''
        },

        addFormVisible: false,
        addLoading: false,


        addForm: {
          text: ''
        }

      }
    },
    methods: {

      handleCurrentChange(val) {
        this.page = val;
        this.getComments();
      },
      formatDate: function (row, column) {
        let cur = new Date(row[column.property]);
        return util.formatDate.format(cur, 'yyyy-MM-dd hh:mm:ss');
      },

      //Get the comments list
      getComments(id) {
        let get_func;
        let para = {};
//        console.log('news-id=', this.news_id);
        if (this.news_id == undefined) {
          para = {
            page: this.page,
            per_page: this.per_page_const,
            name: this.filters.name,
            comment_id: id,
            token: this.$router.token
          };
          get_func = getCommentListPage;

        }else{

          para = {
            page: this.page,
            per_page: this.per_page_const,
            name: this.filters.name,
            article_id: this.news_id,
            token: this.$router.token
          };
          get_func = getArticlesCommentListPage;
        }

        let sort_str = '_id';
        if (this.sort_obj != null){
          sort_str = this.sort_obj.prop;
          if (this.sort_obj.order != 'ascending'){
            sort_str = '-'+ sort_str;
          }
          para["sort"] = sort_str
        }

//        console.log("para=", para)
        this.listLoading = true;
        //NProgress.start() ;

        get_func(para).then((res) => {
          this.total = res.data.count;
          this.comments = res.data.result;
          this.listLoading = false;

          this.$nextTick(_ => {
            if (this.$route.params.id != undefined) {
              console.log("ne ravno")
//              this.handleEdit(1, 1)
              this.editFormVisible = true;
              this.editForm = Object.assign({}, res.data.result[0]);
//              this.cur_user = row.user_name
            }
          })

          //NProgress.done();
        }).catch((err) => {console.log("in catch ggg", err);} );
      },
      // delete
      handleDel: function (index, row) {
        this.$confirm('Are you sure you want to delete the record?', 'warning', {
          type: 'warning'
        }).then(() => {
          this.listLoading = true;
          //NProgress.start();
//          console.log("in DELETE:", this.$router.token, row._id, row);
          let para = { _id: row._id};
          removeComment(para, this.$router.token ).then((res) => {
            let meta = res.data.meta;
//            console.log("meta and res",meta, res)
            if (meta.code != 200) {
              this.listLoading = false;
              this.$message({
                message: 'something wrong!',
                type: 'error'
              });
            }else {
              this.listLoading = false;
              //NProgress.done();
              this.$message({
                message: 'successfully  deleted',
                type: 'success'
              });
              this.getComments();
            }
          });
        }).catch(() => {

        });
      },
      // Edit
      handleEdit: function (index, row) {
        this.editFormVisible = true;
        this.editForm = Object.assign({}, row);
        this.cur_user = row.user_name
      },
      // Create
      handleAdd: function () {
        this.addFormVisible = true;
//        this.getComments();

        this.addForm = {
          text: ''
        };

      },
      cancelEdit: function () {
        this.editFormVisible = false;
//        this.getComments();

        if (this.$route.params.id != undefined) {
          this.$router.push("/comments")
        }
      },
      // Edit save
      editSubmit: function () {
        this.$refs.editForm.validate((valid) => {
          if (valid) {
            this.$confirm('Are you sure ', 'warning', {}).then(() => {
              this.editLoading = true;
              //NProgress.start();
              let para = Object.assign({}, this.editForm);
              // find channel by id and get title

              editComment(para, this.$router.token).then((res) => {
                this.editLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'Submitted successfully',
                  type: 'success'
                });
                this.$refs['editForm'].resetFields();
                this.editFormVisible = false;
                this.getComments();

                });
              if (this.$route.params.id != undefined) {
                this.$router.push("/comments")
              }
            })
          }
        });
      },
//      getComments: function () {
//        let para = { };
//        console.log("in get  Comme");
//        getCommentListPage(para, this.$router.token).then((res) => {
//          this.comments = res.data.result;
//        console.log("resp comm=", this.comments.length);
//        }).catch((err) => {console.log("in catch  ggg", err);} );
//      },

      //
      addSubmit: function () {
        this.$refs.addForm.validate((valid) => {
          if (valid) {
            this.$confirm('Are you sure？', 'warning', {}).then(() => {
              this.addLoading = true;
              //NProgress.start();
              let para = Object.assign({}, this.addForm);
              addComment(para, this.$router.token).then((res) => {
                this.addLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'success',
                  type: 'success'
                });
                this.$refs['addForm'].resetFields();
                this.addFormVisible = false;
                this.getComments();
              });
            });
          }
        });
      },
      selsChange: function (sels) {
        this.sels = sels;
      },
      sortChange: function (obj) {
        console.log("comm Router=", this.$route.params);
//        console.log("sort change(c,p,o)=",obj.column, obj.prop, obj.order)
        this.sort_obj = obj
        this.getComments();
      },

    },
    mounted() {
//      console.log("comm my-props=", this.news_id,  this.$route, this.$route.params);
      this.getComments(this.$route.params.id);
    }
  }

</script>

<style scoped>


</style>