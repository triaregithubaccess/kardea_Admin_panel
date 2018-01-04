<template lang="pug">
  section
    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.name', placeholder='user name')
        el-form-item
          el-button(type='primary', v-on:click='getUsers') Search
        el-form-item
          el-button(type='primary', @click='handleAdd', v-show="false") Add new user
        el-select.left5( v-model="languages" )
          el-option(v-for="item in a_options",
          :key="item.value" ,
          :label="item.label" ,
          :value="item.value")

    el-table(:data='users', highlight-current-row='',
        v-loading='listLoading',
        @sort-change='sortChange',
        @row-click='handleRowClick',
        @selection-change='selsChange',
        style='width: 100%;')
      el-table-column(prop='user_name', label='Name', width='250', sortable='')
      el-table-column(prop='email', label='Email', width='250', sortable='')
      el-table-column(label='Avatar', width='150')
        template( scope="scope")
          img(:src="scope.row.avatar", class="avatar_small")

      el-table-column(prop='sex', label='Sex', width='100', :formatter='formatSex', sortable='')
      el-table-column(prop='birth_year', label='Birth', width='120', sortable='')
      el-table-column(prop='reads', label='Read articles', width='100', :render-header="rere")
      el-table-column(prop='duration', label='Total time spent', width='110')
      el-table-column(prop='language', label='Lang', width='80')

      el-table-column(label='Edit', width='150')
        template(scope='scope')
          el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
          el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-button(type='danger', @click='batchRemove', :disabled='this.sels.length===0') Batch delete
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
    // Edit
    el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false', @close="editCancel")
      el-form(:model='editForm', label-width='80px', :rules='editFormRules', ref='editForm')
        el-form-item(label='Name', prop='user_name')
          el-input(v-model='editForm.user_name', auto-complete='off')
        el-form-item(label='Email', prop='email')
          el-input(v-model='editForm.email', auto-complete='off')
        el-form-item(label='Gender')
          el-radio-group(v-model='editForm.sex')
            el-radio.radio(:label='1' value=1) men
            el-radio.radio(:label='0' value=0) women
        el-form-item(label='Birth Year')
          el-date-picker(type='year', placeholder='birth year', v-model='editForm.birth_year')
        el-form-item(label='Avatar')
          el-upload(class="avatar-uploader",label='Avatar',
          :action="upload_url",
          :show-file-list="false",
          :on-success="handleAvatarSuccess" ,
          :before-upload="beforeAvatarUpload")
            img( v-if="editForm.avatar", :src="editForm.avatar", class="avatar")
            i( v-else class="el-icon-plus  avatar-uploader-icon")
        el-form-item(label='Is admin')
          el-checkbox(v-model='editForm.admin')

      .dialog-footer(slot='footer')
        el-button(@click.native='editCancel') Cancel
        el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
    // Create Interface
    el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
      el-form(:model='addForm', label-width='80px', :rules='addFormRules', ref='addForm')
        el-form-item(label='Name', prop='user_name')
          el-input(v-model='addForm.user_name', auto-complete='off')
        el-form-item(label='Email', prop='email')
          el-input(v-model='addForm.email', auto-complete='off')
        el-form-item(label='Gender')
          el-radio-group(v-model='addForm.sex')
            el-radio.radio(:label='1' value=1) men
            el-radio.radio(:label='0' value=0) women
        el-form-item(label='Birth Year')
          el-date-picker(type='year', placeholder='birth year', v-model='addForm.birth_year')
        el-form-item(label='Avatar')
          el-upload(class="avatar-uploader",label='Avatar',
          :action="upload_url",
          :show-file-list="false",
          :on-success="handleAvatarSuccessAdd" ,
          :before-upload="beforeAvatarUpload")
            img( v-if="addForm.avatar", :src="addForm.avatar", class="avatar")
            i( v-else class="el-icon-plus  avatar-uploader-icon")
        el-form-item(label='Is admin')
          el-checkbox(v-model='addForm.admin')
        el-form-item(label='Password', v-if="addForm.admin")
          el-input(type="password", v-model='addForm.password')
        el-form-item(label='Repeat password', v-if="addForm.admin")
          el-input(type="password", v-model='addForm.password2')
      .dialog-footer(slot='footer')
        el-button(@click.native='addFormVisible = false') Cancel
        el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Submit

</template>

<script>
	import util from '../../common/js/util'
	//import NProgress from 'nprogress'
	import { getUserListPage, removeUser, batchRemoveUser, editUser, api_domen,addUser,image_upload_url2 } from '../../api/api';

	export default {
    watch: {
      'languages': function () {
        this.getUsers();
      }
    },

    data() {
			return {
        upload_url: image_upload_url2,
				filters: {
					name: ''
				},

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

				users: [],
        sort_obj: null,
				total: 0,
				page: 1,
        per_page_const: 10,
				listLoading: false,
				sels: [],//selected rows

				editFormVisible: false,
				editLoading: false,
				editFormRules: {
					name: [
						{ required: true, message: 'Please type user name', trigger: 'blur' }
					]
				},
				// Edit
				editForm: {

					user_name: '',
					birth_year: '',
					sex: -1,
					email: '',
          admin: '',
					avatar: ''
				},

				addFormVisible: false,
				addLoading: false,
				addFormRules: {
					name: [
						{ required: true, message: 'Not filled!', trigger: 'blur' }
					]
				},
				addForm: {
          user_name: '',
          birth_year: '',
          sex: -1,
          email: '',
          admin: false,
          avatar: '',
          password: '',
          password2: ''
				}

			}
		},
		methods: {
      get_lang() {
        if (this.languages == 'de,en') { return ''
        }else{ return this.languages }
      },

      rere: function (h,b) {
//        console.log(h)
//        console.log(b)
//        console.log("lab=", b.column.label)
        return h('div', {}, ["Read",h('br'),"articles"])
      },
      sortChange: function (obj) {
        this.sort_obj = obj
        this.getUsers();
      },
      handleAvatarSuccess(file, fileList) {
        this.editForm.avatar = api_domen + file.result
      },
      handleAvatarSuccessAdd(file, fileList) {
        this.addForm.avatar = api_domen + file.result
      },
      beforeAvatarUpload(file) {
      },

      //Gender display conversion
			formatSex: function (row, column) {
				return row.sex == 1 ? 'man' : row.sex == 0 ? 'women' : 'unknown';
			},
			handleCurrentChange(val) {
				this.page = val;
				this.getUsers();
			},
			//Get the user list
			getUsers() {
				let para = {
          page: this.page,
          per_page: this.per_page_const,
          language: this.languages,
					name: this.filters.name
				};
				this.listLoading = true;
        let sort_str = '_id';
        if (this.sort_obj != null){
          sort_str = this.sort_obj.prop;
          if (this.sort_obj.order != 'ascending'){
            sort_str = '-'+ sort_str;
          }
          para["sort"] = sort_str
        }

        // console.log("GGG getUsers...before req");
				getUserListPage(para, this.$router.token).then((res) => {

					//console.log("GGG getUsers...,,,", res.data.result.length, res.data.result);
					this.total = res.data.count;
					this.users = res.data.result;
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
          //console.log("in DELETE:", this.$router.token, row._id, row);
					let para = { _id: row._id};
					removeUser(para, this.$router.token ).then((res) => {
						let meta = res.data.meta;
						//console.log("meta and res",meta, res)
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
							this.getUsers();
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
          user_name: '',
          birth_year: '',
          sex: -1,
          email: '',
          admin: false,
          avatar: ''
				};
			},
			// Edit save
			editSubmit: function () {
				this.$refs.editForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure？', 'warning', {}).then(() => {
							this.editLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.editForm);
							para.birth = (!para.birth || para.birth == '') ? '' : util.formatDate.format(new Date(para.birth), 'yyyy-MM-dd');
							editUser(para, this.$router.token).then((res) => {
								this.editLoading = false;
								//NProgress.done();
								this.$message({
									message: 'Submitted successfully',
									type: 'success'
								});
								this.$refs['editForm'].resetFields();
								this.editFormVisible = false;
								this.getUsers();
							});
						});
					}
				});
			},
      // Edit cancel
      editCancel: function () {
        this.editFormVisible = false;
        this.$refs['editForm'].resetFields();
      },
			addSubmit: function () {
				this.$refs.addForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure？', 'warning', {}).then(() => {
							this.addLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.addForm);
							para.birth_year = util.formatDate.format(new Date(para.birth_year), 'yyyy');
							addUser(para, this.$router.token).then((res) => {
								this.addLoading = false;
								//NProgress.done();
								this.$message({
									message: 'Success',
									type: 'success'
								});
								this.$refs['addForm'].resetFields();
								this.addFormVisible = false;
								this.getUsers();
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
			//mass delete
			batchRemove: function () {
				var ids = this.sels.map(item => item.id).toString();
				this.$confirm('Are you sure you want to delete the selected record？', 'warning', {
					type: 'warning'
				}).then(() => {
					this.listLoading = true;
					//NProgress.start();
					let para = { ids: ids };
					batchRemoveUser(para, this.$router.token).then((res) => {
						this.listLoading = false;
						//NProgress.done();
						this.$message({
							message: 'successfully deleted',
							type: 'success'
						});
						this.getUsers();
					});
				}).catch(() => {

				});
			}
		},
		mounted() {
			this.getUsers();
		}
	}

</script>

<style scoped>
.avatar {
  max-width: 177px;
  max-height: 177px;
  display: block;
}
.avatar_small {
  max-width: 77px;
  max-height: 77px;
  /*height: 178px;*/
  /*display: block;*/
}
</style>