<template lang="pug">
  section

    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.text', placeholder='words')
        el-form-item
          el-button(type='primary', v-on:click='getDefinitions') Search
        el-form-item
          el-button(type='primary',  @click='handleAdd') Add new Definition

    el-table(:data='definitions', highlight-current-row='',
        v-loading='listLoading',
        @selection-change='selsChange',
        @sort-change='sortChange',

        style='width: 100%;')
      el-table-column(prop='term', label='Term',  sortable='')

      el-table-column(prop='explanation', label='Explanation',  sortable='')
      el-table-column(prop='category', label='Category',  sortable='')

      el-table-column(prop='created_at', label='Created at', width='200', sortable='', :formatter='formatDate')
      el-table-column(label='Edit', width='150')
        template(scope='scope')
          el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
          el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :current-page='page',:total='total', style='float:right;')
    // Edit
    el-dialog(:title="Edit", v-model='editFormVisible', :close-on-click-modal='false')
      el-form(:model='editForm', label-width='80px',  ref='editForm')

        el-form-item(label='Term', prop='term')
          el-input(v-model='editForm.term', auto-complete='off')
        el-form-item(label='Explanation', prop='explanation')
          el-input(v-model='editForm.explanation', auto-complete='off')
        el-form-item(label='Category', prop='category')
          el-input(v-model='editForm.category', auto-complete='off')


      .dialog-footer(slot='footer')
        el-button(@click.native='cancelEdit') Cancel
        el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
    // Create Interface
    el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
      el-form(:model='addForm', label-width='80px',  ref='addForm')

        el-form-item(label='Term', prop='term')
          el-input(v-model='addForm.term', auto-complete='off')
        el-form-item(label='Explanation', prop='explanation')
          el-input(v-model='addForm.explanation', auto-complete='off')
        el-form-item(label='Category', prop='category')
          el-input(v-model='addForm.category', auto-complete='off')

      .dialog-footer(slot='footer')
        el-button(@click.native='addFormVisible = false') Cancel
        el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  //import NProgress from 'nprogress'
  import { getDefinitionListPage, removeDefinition, editDefinition, addDefinition } from '../api/api';
  export default {
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
        definitions: [],
        total: 0,
        page: 2,
        per_page_const: 10,
        listLoading: false,
        sels: [],//selected rows

        editFormVisible: false,
        editLoading: false,

        // Edit
        editForm: {
          term: '',
          explanation: '',
          category: ''
        },

        addFormVisible: false,
        addLoading: false,


        addForm: {
          term: '',
          explanation: '',
          category: ''
        }

      }
    },
    methods: {

      handleCurrentChange(val) {
        this.page = val;
        this.getDefinitions();
      },
      formatDate: function (row, column) {
        let cur = new Date(row[column.property]);
        return util.formatDate.format(cur, 'yyyy-MM-dd hh:mm:ss');
      },

      //Get the definitions list
      getDefinitions(id) {
        let para = {};
        para = {
          page: this.page,
          per_page: this.per_page_const,
          name: this.filters.name,
          token: this.$router.token
        };

        let sort_str = '_id';
        if (this.sort_obj != null){
          sort_str = this.sort_obj.prop;
          if (this.sort_obj.order != 'ascending'){
            sort_str = '-'+ sort_str;
          }
          para["sort"] = sort_str
        }

        this.listLoading = true;
        //NProgress.start() ;

        getDefinitionListPage(para).then((res) => {
          this.total = res.data.count;
          this.definitions = res.data.result;
          this.listLoading = false;

          this.$nextTick(_ => {
            if (this.$route.params.id != undefined) {
              this.editFormVisible = true;
              this.editForm = Object.assign({}, res.data.result[0]);
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
          removeDefinition(para, this.$router.token ).then((res) => {
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
              this.getDefinitions();
            }
          });
        }).catch(() => {

        });
      },
      // Edit
      handleEdit: function (index, row) {
        this.editFormVisible = true;
        this.editForm = Object.assign({}, row);
      },
      // Create
      handleAdd: function () {
        this.addFormVisible = true;
        this.addForm = {
          term: '',
          explanation: '',
          category: ''
        };

      },
      cancelEdit: function () {
        this.editFormVisible = false;
        if (this.$route.params.id != undefined) {
          this.$router.push("/definitions")
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

              editDefinition(para, this.$router.token).then((res) => {
                this.editLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'Submitted successfully',
                  type: 'success'
                });
                this.$refs['editForm'].resetFields();
                this.editFormVisible = false;
                this.getDefinitions();

                });
              if (this.$route.params.id != undefined) {
                this.$router.push("/definitions")
              }
            })
          }
        });
      },
      //
      addSubmit: function () {
        this.$refs.addForm.validate((valid) => {
          if (valid) {
            this.$confirm('Are you sure？', 'warning', {}).then(() => {
              this.addLoading = true;
              //NProgress.start();
              let para = Object.assign({}, this.addForm);
              addDefinition(para, this.$router.token).then((res) => {
                this.addLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'success',
                  type: 'success'
                });
                this.$refs['addForm'].resetFields();
                this.addFormVisible = false;
                this.getDefinitions();
              });
            });
          }
        });
      },
      selsChange: function (sels) {
        this.sels = sels;
      },
      sortChange: function (obj) {
        this.sort_obj = obj
        this.getDefinitions();
      },

    },
    mounted() {
      this.getDefinitions(this.$route.params.id);
    }
  }

</script>

<style scoped>


</style>