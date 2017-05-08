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
	    el-table-column(type='selection', width='55')
	    el-table-column(type='index', width='60')
	    el-table-column(prop='user_name', label='Name', width='100', sortable='')
	    el-table-column(prop='sex', label='Sex', width='100', :formatter='formatSex', sortable='')
	    el-table-column(prop='_id', label='Age3', width='150', sortable='')
	    el-table-column(prop='age', label='Age', width='150', sortable='')
	    el-table-column(prop='birth_year', label='Birth', width='120', sortable='')
	    el-table-column(prop='addr', label='Addr', min-width='180', sortable='')
	    el-table-column(label='Edit', width='150')
	      template(scope='scope')
	        el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
	        el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
	  el-col.toolbar(:span='24')
	    el-button(type='danger', @click='batchRemove', :disabled='this.sels.length===0') Batch delete
	    el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='20', :total='total', style='float:right;')
	  // Edit-->
	  el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
	    el-form(:model='editForm', label-width='80px', :rules='editFormRules', ref='editForm')
	      el-form-item(label='Name', prop='user_name')
	        el-input(v-model='editForm.user_name', auto-complete='off')
	      el-form-item(label='Gender')
	        el-radio-group(v-model='editForm.sex')
	          el-radio.radio(:label='1' value=1) men
	          el-radio.radio(:label='0' value=0) women
	      el-form-item(label='Birth Year')
	        el-date-picker(type='year', placeholder='year', v-model='editForm.birth_year')
	    .dialog-footer(slot='footer')
	      el-button(@click.native='editFormVisible = false') Cancel
	      el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
	  // Create Interface
	  el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
	    el-form(:model='addForm', label-width='80px', :rules='addFormRules', ref='addForm')
	      el-form-item(label='姓名', prop='name')
	        el-input(v-model='addForm.name', auto-complete='off')
	      el-form-item(label='性别')
	        el-radio-group(v-model='addForm.sex')
	          el-radio.radio(:label='1') man
	          el-radio.radio(:label='0') women
	      el-form-item(label='年龄')
	        el-input-number(v-model='addForm.age', :min='0', :max='200')
	      el-form-item(label='生日')
	        el-date-picker(type='date', placeholder='选择日期', v-model='addForm.birth')
	      el-form-item(label='地址')
	        el-input(type='textarea', v-model='addForm.addr')
	    .dialog-footer(slot='footer')
	      el-button(@click.native='addFormVisible = false') 取消
	      el-button(type='primary', @click.native='addSubmit', :loading='addLoading') 提交

</template>

<script>
	import util from '../../common/js/util'
	//import NProgress from 'nprogress'
	import { getUserListPage, removeUser, batchRemoveUser, editUser, addUser } from '../../api/api';

	export default {
		data() {
			return {
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
					id: 0,
					name: '',
					sex: -1,
					age: 0,
					birth: '',
					addr: ''
				},

				addFormVisible: false,//新增界面是否显示
				addLoading: false,
				addFormRules: {
					name: [
						{ required: true, message: '请输入姓名', trigger: 'blur' }
					]
				},
				//新增界面数据
				addForm: {
					name: '',
					sex: -1,
					age: 0,
					birth: '',
					addr: ''
				}

			}
		},
		methods: {
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
				console.log("GGG getUsers...before req");
				getUserListPage(para).then((res) => {

					console.log("GGG getUsers...,,,", res.data.result.length, res.data.result);
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
				    console.log("in DELETE:", this.$router.token, row._id, row);
					let para = { _id: row._id, token: this.$router.token };
					removeUser(para).then((res) => {
						let meta = res.data.meta;
						console.log("meta and res",meta, res)
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
					name: '',
					sex: -1,
					age: 0,
					birth: '',
					addr: ''
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
							editUser(para).then((res) => {
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
			//新增
			addSubmit: function () {
				this.$refs.addForm.validate((valid) => {
					if (valid) {
						this.$confirm('确认提交吗？', 'warning', {}).then(() => {
							this.addLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.addForm);
							para.birth = (!para.birth || para.birth == '') ? '' : util.formatDate.format(new Date(para.birth), 'yyyy-MM-dd');
							addUser(para).then((res) => {
								this.addLoading = false;
								//NProgress.done();
								this.$message({
									message: '提交成功',
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
			//批量删除
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