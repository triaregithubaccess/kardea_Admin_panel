<template lang="pug">
  section
    el-col.toolbar(:span='24', style='padding-bottom: 0px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.name', placeholder='user name')
        el-form-item
          el-button(type='primary', v-on:click='getUsers') Search
        el-form-item
          el-button(type='primary', @click='handleAdd') Add new user
    el-table(:data='users', highlight-current-row='', v-loading='listLoading', @selection-change='selsChange', style='width: 100%;')
      el-table-column(prop='user_name', label='Name', width='100', sortable='')
      el-table-column(prop='email', label='Email', width='200', sortable='')
      el-table-column(label='Avatar', width='150')
        template( scope="scope")
          img(:src="scope.row.avatar + '?width=100&height=100'")

      el-table-column(prop='sex', label='Sex', width='100', :formatter='formatSex', sortable='')
      el-table-column(prop='birth_year', label='Birth', width='120', sortable='')
      el-table-column(label='Edit', width='150')
        template(scope='scope')
          el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
          el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-button(type='danger', @click='batchRemove', :disabled='this.sels.length===0') Batch delete
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='20', :total='total', style='float:right;')
    // Edit
    el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
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
        el-button(@click.native='editFormVisible = false') Cancel
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
          :on-success="handleAvatarSuccess" ,
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
	import { getUserListPage, removeUser, batchRemoveUser, editUser, addUser,image_upload_url2 } from '../../api/api';

	export default {
		data() {
			return {
        upload_url: image_upload_url2,
				filters: {
					name: ''
				},
				users: [],
				total: 0,
				page: 1,
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
      handleAvatarSuccess(file, fileList) {
//        console.log(' Success pic!!');
        this.editForm.avatar = api_domen + file.result
      },
      handleAvatarSuccessAdd(file, fileList) {
//        console.log(' Success pic!!');
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
					name: this.filters.name
				};
				this.listLoading = true;
				//NProgress.start();
				//console.log("GGG getUsers...before req");
				getUserListPage(para).then((res) => {

					//console.log("GGG getUsers...,,,", res.data.result.length, res.data.result);
					this.total = res.data.result.length;
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

			addSubmit: function () {
				this.$refs.addForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure？', 'warning', {}).then(() => {
							this.addLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.addForm);
							para.birth_year = util.formatDate.format(new Date(para.birth_year), 'yyyy');
							console.log("para=", para)
							addUser(para, this.$router.token).then((res) => {
							  console.log("res=", res)
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
					batchRemoveUser(para).then((res) => {
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

</style>