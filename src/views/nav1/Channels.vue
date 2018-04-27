<template lang="pug">
  section
    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.name', placeholder='topic name')
        el-form-item
          el-button(type='primary', v-on:click='getChannels') Search
        el-form-item
          el-button(type='primary', @click='handleAdd') Add new Topic
        el-select.left5( v-model="languages" )
          el-option(v-for="item in a_options",
          :key="item.value" ,
          :label="item.label" ,
          :value="item.value")

    el-table(:data='channels', highlight-current-row='',:default-sort='desort', v-loading='listLoading', @row-click='handleRowClick', @selection-change='selsChange', style='width: 100%;')
      el-table-column(type='expand', width='55')
        template( scope="props")
          p
            b Description :
            |  {{ props.row.description }}
          article_list(:che_id='props.row._id', :lang='props.row.language')
      //el-table-column(prop='_id', label='ID', width='200', sortable='')
      el-table-column(prop='title', label='Title', width='200', sortable='')
      el-table-column(label='Picture', width='150')
        template( scope="scope")
          img(:src="scope.row.picture   + '?width=100&height=100'")
      <!--el-table-column(label='Wide Pic')-->
        <!--template( scope="scope")-->
          <!--img(:src="scope.row.wide_picture   + '?width=150&height=150'")-->

      el-table-column(prop='position', label='Pos', width='100', sortable='')
      el-table-column(prop='access_code', label='code', width='100', sortable='')
      el-table-column(prop='s_on_s', label='Auto subscribed', width='100', sortable='', :formatter='formatBool')
      el-table-column(prop='updated_at', label='Updated at', width='200', sortable='', :formatter='formatDate')
      el-table-column(prop='created_at', label='Created at', width='200', sortable='', :formatter='formatDate')
      el-table-column(prop='language', label='Lang', width='80')
      el-table-column(label='Edit', width='250')
        template(scope='scope')
          el-row(:span="24",align="middle", type="flex")

            el-col( :span="3")
              el-row()
                el-button(size='mini', @click='handleUp(scope.$index, scope.row)') ⇑
              el-row()
                el-button(size='mini', @click='handleDown(scope.$index, scope.row)') ⇓
            el-col( :span="20")
              el-row(align="bottom")
                el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
                el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
    // Edit
    el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
      el-form(:model='editForm', label-width='80px', :rules='formRulesEdit', ref='editForm')
        el-form-item(label='Title', prop='title')
          el-input(v-model='editForm.title', auto-complete='off')
        el-form-item(label='Description', prop='description')
          el-input(type="textarea" , v-model='editForm.description', auto-complete='off')
        el-form-item(label='Access code', prop='access_code')
          el-input( v-model='editForm.access_code', :disabled="editForm.s_on_s ")
        el-form-item(label='Language', prop='language')
          el-select(type='year', placeholder='language', v-model='editForm.language')
            el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
        el-form-item(label='Auto subscribed', prop='s_on_s')
          el-checkbox( v-model='editForm.s_on_s', :disabled="editForm.access_code != undefined && editForm.access_code.length > 0")
        el-form-item(label='Show in Topic only', prop='in_channel_only')
          el-checkbox( v-model='editForm.in_channel_only')
        el-form-item(label='Related to the user health', prop='by_tags_only')
          el-checkbox( v-model='editForm.by_tags_only')
        el-form-item(label='Picture', prop='picture')
          el-upload(class="avatar-uploader",label='Picture',
          :action="upload_url",
          :show-file-list="false",
          :on-success="handlePictureSuccess" ,
          :before-upload="beforePictureUpload")
            span.ggg
              img( v-if="editForm.picture", :src="editForm.picture", class="avatar")
              i( v-else class="el-icon-plus avatar-uploader-icon")
        <!--el-form-item(label='Wide Picture')-->
          <!--el-upload(class="avatar-uploader",label='Wide Picture',-->
          <!--:action="upload_url",-->
          <!--:show-file-list="false",-->
          <!--:on-success="handleWPictureSuccess" ,-->
          <!--:before-upload="beforePictureUpload")-->
            <!--span.ggg-->
              <!--img( v-if="editForm.wide_picture", :src="editForm.wide_picture", class="avatar")-->
              <!--i( v-else class="el-icon-plus avatar-uploader-icon")-->
        el-form-item(label='Position', prop='position')
          el-inputNumber(type="textarea" , v-model='editForm.position', auto-complete='off')

      .dialog-footer(slot='footer')
        el-button(@click.native='editFormVisible = false') Cancel
        el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
    // Create Interface
    el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
      el-form(:model='addForm', label-width='80px', :rules='formRulesAdd', ref='addForm')
        el-form-item(label='Title', prop='title')
          el-input(v-model='addForm.title', auto-complete='off')
        el-form-item(label='Description', prop='description')
          el-input(type="textarea" , v-model='addForm.description', auto-complete='off')
        el-form-item(label='Access code', prop='access_code')
          el-input( v-model='addForm.access_code', :disabled="addForm.s_on_s")
        el-form-item(label='Language', prop='language')
          el-select(type='year', placeholder='language', v-model='addForm.language')
            el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
        el-form-item(label='Auto subscribed', prop='s_on_s')
          el-checkbox( v-model='addForm.s_on_s' , :disabled="addForm.access_code != undefined && addForm.access_code.length > 0")
        el-form-item(label='Show in Topic only', prop='in_channel_only')
          el-checkbox( v-model='addForm.in_channel_only')
        el-form-item(label='Related to the user health', prop='by_tags_only')
          el-checkbox( v-model='addForm.by_tags_only')

        el-form-item(label='Picture', prop='picture')
          .grey Optimal size: under 5 Mb
          el-upload(class="avatar-uploader",label='Picture',
          :action="upload_url",
          :show-file-list="false",
          :on-success="handlePictureSuccessAdd" ,
          :before-upload="beforePictureUpload")
            span.ggg
              img( v-if="addForm.picture", :src="addForm.picture", class="avatar")
              i( v-else class="el-icon-plus avatar-uploader-icon")
        <!--el-form-item(label='Wide Picture')-->
          <!--el-upload(class="avatar-uploader",label='Wide Picture',-->
          <!--:action="upload_url",-->
          <!--:show-file-list="false",-->
          <!--:on-success="handleWPictureSuccessAdd" ,-->
          <!--:before-upload="beforePictureUpload")-->
            <!--span.ggg-->
              <!--img( v-if="addForm.wide_picture", :src="addForm.wide_picture", class="avatar")-->
              <!--i( v-else class="el-icon-plus avatar-uploader-icon")-->
        el-form-item(label='Position', prop='position')
          el-inputNumber(type="textarea" , v-model='addForm.position', auto-complete='off')

      .dialog-footer(slot='footer')
        el-button(@click.native='addFormVisible = false') Cancel
        el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script>
  import util from '../../common/js/util'
  import articles from '../../components/Articles'
  //import NProgress from 'nprogress'
  import { getChannelListPage, removeChannel, batchRemoveChannel, editChannel, addChannel,  api_domen, image_upload_url2 } from '../../api/api';

  export default {
    components: {
      'article_list': articles
    },
    watch: {
      'languages': function () {
        this.getChannels();
      },
      'access_code': function () {
        this.getChannels();
      },
      'languages': function () {
        this.getChannels();
      }
    },

    data() {
      var nonEmptyAndRequired = (rule, value, callback) => {
        if (value.trim() === '' || value == undefined) {
          callback(new Error('Empty not allowed!'));
        } else {
          callback();
        }
      };

//      var mustNotTwoAdd = (rule, value, callback) => {
//        if (this.addForm.access_code == undefined  && this.addForm.s_on_s == undefined ) {
//          callback();
//        } else {
//          if ((this.addForm.access_code.trim() != '') && this.addForm.s_on_s ){
//            callback(new Error('Incorrect set access code and auto-subscribe'));
//        }else{
//            callback();
//          }
//        }
//      };
//
//      var mustNotTwoEdit = (rule, value, callback) => {
//        if (this.editForm.access_code == undefined  && this.editForm.s_on_s == undefined ) {
//          callback();
//        } else {
//          if ((this.editForm.access_code.trim() != '') && this.editForm.s_on_s ){
//            callback(new Error('Incorrect set access code and auto-subscribe'));
//          }else{
//            callback();
//          }
//        }
//
//      };

      var mustUniqEdit = (rule, value, callback) => {
        if (value == undefined || value.trim() === '' ) {
          callback();
        } else {
          let uniq = true
          this.channels.forEach((x) =>{
            if (this.editForm._id != x._id) {
              if (x.access_code === value) {
                uniq = false
              }
            }
          })
          if (uniq) {
            callback()
          }else {
            callback(new Error('Empty not allowed!'));
          }
        }
      };

      var mustUniqAdd = (rule, value, callback) => {
        if (value == undefined || value.trim() === '' ) {
          callback();
        } else {
          let uniq = true
          this.channels.forEach((x) =>{
            if (this.addForm._id != x._id) {
              if (x.access_code === value) {
                uniq = false
              }
            }
          })
          if (uniq) {
            callback()
          }else {
            callback(new Error('Empty not allowed!'));
          }
        }
      };

      return {
        upload_url: image_upload_url2,
        desort: {
          prop: "position" ,
          order: "ascending" },


        languages: 'de,en',
        a_options: [{
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
          text: 'DE',
          label: 'DE'
          },
          {
          value: 'en',
          text: 'EN',
          label: 'EN'
          },
            ],
        filters: {
          name: ''
        },
        channels: [],
        total: 0,
        page: 1,
        per_page_const: 100,
        listLoading: false,
        sels: [],//selected rows

        editFormVisible: false,
        editLoading: false,

        formRulesEdit: {
          title: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Title', trigger: 'blur' } ] ,
          access_code: [ { validator: mustUniqEdit, message: 'Not uniq', trigger: 'blur' } ] ,
          description: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Description', trigger: 'blur' } ],
          language: [ { required: true, message: 'Please input Language', trigger: 'blur' } ],
          picture: [ { required: true, message: 'Please upload Picture', trigger: 'blur' } ],
        },
        formRulesAdd: {
          title: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Title', trigger: 'blur' } ] ,
          access_code: [ { validator: mustUniqAdd, message: 'Not uniq', trigger: 'blur' } ] ,
          description: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Description', trigger: 'blur' } ],
          language: [ { required: true, message: 'Please input Language', trigger: 'blur' } ],
          picture: [ { required: true, message: 'Please upload Picture', trigger: 'blur' } ],
        },

        // Edit
        editForm: {
          title: '',
          description: '',
          picture: '',
          language: '',
          position: '',
          access_code: '',
          s_on_s: false,
          in_channel_only: false,
          by_tags_only: false,
          iuu: image_upload_url2,
        },

        addFormVisible: false,
        addLoading: false,

        addForm: {
          title: '',
          description: '',
          picture: '',
          position: '',
          access_code: '',
          s_on_s: false,
          in_channel_only: false,
          by_tags_only: false,
          language: '',
          iuu: image_upload_url2,

        }

      }
    },
    methods: {
      get_lang() {
        if (this.languages == 'de,en') { return ''
        }else{ return this.languages }
      },
      handlePictureSuccess(file, fileList) {
//        console.log(' Success picE!!');
        this.editForm.picture = api_domen + file.result
      },
      handlePictureSuccessAdd(file, fileList) {
//        console.log(' Success picA!!');
        this.addForm.picture = api_domen + file.result
      },
//      handleWPictureSuccess(file, fileList) {
//        console.log(' Success picWE!!');
//        this.editForm.wide_picture = api_domen + file.result
//      },
//      handleWPictureSuccessAdd(file, fileList) {
//        console.log(' Success picWA!!');
//        this.addForm.wide_picture = api_domen + file.result
//      },
      beforePictureUpload(file) {
//        console.log(file);
      },

      handleAvatarSuccess(file, fileList) {
        this.editForm.picture = api_domen + file.result
      },
      beforeAvatarUpload(file) {
//        console.log(file);
      },

      filterLang(value, row) {
        return row.language === value;
      },

      handleCurrentChange(val) {
        this.page = val;
        this.getChannels();
      },
      formatDate: function (row, column) {
        let cur = new Date(row[column.property]);
        return util.formatDate.format(cur, 'yyyy-MM-dd hh:mm:ss');
      },

      formatBool: function (row, column) {
        if (row[column.property]) {
          return "Yes"
        } else{
          return ""
        }

      },

      //Get the channel list
      getChannels() {
        let para = {
          page: this.page,
          per_page: this.per_page_const,
          language: this.languages,
          name: this.filters.name
        };
        this.listLoading = true;
        //NProgress.start();
        getChannelListPage(para).then((res) => {
          this.total = res.data.count;
          this.channels = res.data.result;
          this.listLoading = false;
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
//            console.log("in DELETE:", this.$router.token, row._id, row);
          let para = { _id: row._id};
          removeChannel(para, this.$router.token).then((res) => {
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
              this.getChannels();
            }
          });
        }).catch(() => {

        });
      },
      // Edit
      handleEdit: function (index, row) {
        if (row.s_on_s == undefined) { row.s_on_s = false }
        if (row.access_code == undefined) { row.access_code = '' }
        if (row.in_channel_only == undefined) { row.in_channel_only = '' }
        if (row.by_tags_only == undefined) { row.by_tags_only = '' }
        this.editFormVisible = true;
        this.editForm = Object.assign({}, row);
      },
      // Move Up
      handleUp: function (index, row) {
        if (index == 0) {return}
        this.editLoading = true;
        let para = Object.assign({}, row);
        var new_pos = this.channels[index-1].position - 1;
        if  (new_pos < 1){
           new_pos = 1;
        }
        para.position = new_pos;
        editChannel(para, this.$router.token).then((res) => {
          this.editLoading = false;
          this.getChannels();
        });

      },
      // Move Down
      handleDown: function (index, row) {
        if (index == this.channels.length-1) {return}
        this.editLoading = true;
        let para = Object.assign({}, row);
        para.position = this.channels[index+1].position + 1;
        editChannel(para, this.$router.token).then((res) => {
          this.editLoading = false;
          this.getChannels();
        });

      },
      // Create
      handleAdd: function () {
        this.addFormVisible = true;

        this.addForm = {
          title: '',
          description: '',
          picture: '',
          language: this.get_lang(),
          position: '',
          access_code: '',
          s_on_s: false,
          in_channel_only: false,
          by_tags_only: false
        };
        //this.addForm.language = this.get_lang();
        //console.log(this.addForm)
      },
      // Edit save
      editSubmit: function () {
        this.$refs.editForm.validate((valid) => {
          if (valid) {
            this.$confirm('Are you sure？', 'warning', {}).then(() => {
              this.editLoading = true;
              //NProgress.start();
              let para = Object.assign({}, this.editForm);
              editChannel(para, this.$router.token).then((res) => {
                this.editLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'Submitted successfully',
                  type: 'success'
                });
                this.$refs['editForm'].resetFields();
                this.editFormVisible = false;
                this.getChannels();
              });
            });
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
              para.birth = (!para.birth || para.birth == '') ? '' : util.formatDate.format(new Date(para.birth), 'yyyy-MM-dd');
              addChannel(para, this.$router.token).then((res) => {
                this.addLoading = false;
                //NProgress.done();
                this.$message({
                  message: 'success',
                  type: 'success'
                });
                this.$refs['addForm'].resetFields();
                this.addFormVisible = false;
                this.getChannels();
              });
            });
          }
        });
      },
      handleRowClick: function (row,event,column) {
        //console.log("row click",row,event,column)
        if (column.className == "el-table__expand-column" || column.label == 'Edit') {
        } else {
          this.handleEdit(1, row)
        }
      } ,

      selsChange: function (sels) {
        this.sels = sels;
      },
      //
      batchRemove: function () {
        var ids = this.sels.map(item => item.id).toString();
        this.$confirm('Are you sure you want to delete the selected record？', 'warning', {
          type: 'warning'
        }).then(() => {
          this.listLoading = true;
          //NProgress.start();
          let para = { ids: ids };
          batchRemoveChannel(para).then((res) => {
            this.listLoading = false;
            //NProgress.done();
            this.$message({
              message: 'successfully deleted',
              type: 'success'
            });
            this.getChannels();
          });
        }).catch(() => {

        });
      }
    },
    mounted() {
      this.getChannels();
    }
  }

</script>

<style scoped>
.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}
.avatar-uploader .el-upload:hover {
  border-color: #20a0ff;
}
.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  line-height: 178px;
  text-align: center;
}
.avatar {
  width: 178px;
  height: 178px;
  display: block;
}
.ggg {
  display: inline-block;
  width: 164px;
  height: 164px;
  border: 1px solid #888;
  position: relative;
}
.ggg img {
  max-width:164px;
  max-height:164px;
  width:auto;
  height:auto;
  border: 0;
  position: absolute;
  top: 0; right: 0; bottom: 0; left: 0;
  margin: auto;
}
.grey{
  color: #bfd9d0;
}

</style>