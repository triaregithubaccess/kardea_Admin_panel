<template lang="pug">
	section
		el-col.toolbar(:span='22', style='padding-bottom: 0px;')
				el-form(:inline='true', :model='filters')
					el-form-item
						el-input(v-model='filters.name', placeholder='tag name')
					el-form-item
						el-button(type='primary', v-on:click='getTags') Search
					el-form-item
						el-button(type='primary', @click='handleAdd') Addnew{{name_t}}--

		el-col(:span="22")
			h3 {{name_t}}
			el-table(:data='items', highlight-current-row='',
					v-loading='listLoading',
					@selection-change='selsChange',
					@sort-change='sortChange',

					style='width: 100%;')

				el-table-column(:prop='myp.f1', :label='myp.f1', width='250', sortable='')
				el-table-column(label='Edit', width='150')
					template(scope='scope')
						el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
						el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete

		el-col.toolbar(:span='22')
			el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:left;')
			// Edit
			el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
				el-form(:model='editForm', label-width='80px',  ref='editForm')
					el-form-item(label='Name',width='250', prop='name')
						el-input(v-model='editForm.name', auto-complete='off')

				.dialog-footer(slot='footer')
					el-button(@click.native='editFormVisible = false') Cancel
					el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
			// Create Interface
			el-dialog(title='New',size='tiny', v-model='addFormVisible', :close-on-click-modal='false')
				el-form(:model='addForm', label-width='80px',  ref='addForm')
					el-form-item(:label='myp.f1', prop='name')
						el-input(v-model='addForm[myp.f1]', auto-complete='off')

				.dialog-footer(slot='footer')
					el-button(@click.native='addFormVisible = false') Cancel
					el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
	import util from '../common/js/util'
	import _ from 'lodash'

	export default {
		props: ['myp','name_t'],



		data() {
			return {
				filters: {
					name: ''
				},
				sort_obj: null,
	      items: [],
				total: 0,
				page: 1,
				per_page_const: 4,
				listLoading: false,
				sels: [],

				editFormVisible: false,
				editLoading: false,

				editForm: {
					name: ''
				},

				addFormVisible: false,
				addLoading: false,

				addForm: {
					name: ''
				}

			}
		},
		methods: {

			handleCurrentChange(val) {
				this.page = val;
				this.getTags();
			},

			//Get the Tag list
			getTags() {
				let para2 = {
						page: this.page,
						per_page: this.per_page_const,
						search: this.filters.name,
						token: this.$router.token
				};

				let sort_str = '_id';
				if (this.sort_obj != null){
					sort_str = this.sort_obj.prop;
					if (this.sort_obj.order != 'ascending'){
						sort_str = '-'+ sort_str;
					}
					para2["sort"] = sort_str
				}

				console.log("para2=", para2)
				this.listLoading = true;
				//NProgress.start();

					this.myp.getList(para2).then((res) => {
					this.total = res.data.count;
					this.items = res.data.result;
					this.listLoading = false;
					//NProgress.done();
				}).catch((err) => {console.log("in catch ggg", err);} );
			},
			//  delete
			handleDel: function (index, row) {
				this.$confirm('Are you sure you want to delete the record?', 'warning', {
					type: 'warning'
				}).then(() => {
					this.listLoading = true;
					//NProgress.start();
				    console.log("in DELETE:", this.$router.token, row._id, row);
					let para = { _id: row._id, token: this.$router.token };
					removeTag(para).then((res) => {
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
							this.getTags();
						}
					});
				}).catch(() => {

				});
			},
			// Edit
			handleEdit: function (index, row) {
				this.editFormVisible = true;
				this.getTags();
				this.editForm = Object.assign({}, row);
			},
			// Create
			handleAdd: function () {
				console.log("add clicked")
				this.addFormVisible = true;
        this.getTags();

				this.addForm = {}
				this.addForm[this.myp.f1] = ''

			},
			// Edit save
			editSubmit: function () {
				this.$refs.editForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure ', 'warning', {}).then(() => {
							this.editLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.editForm);

							editTag(para, this.$router.token).then((res) => {
								this.editLoading = false;
								//NProgress.done();
								this.$message({
									message: 'Submitted successfully',
									type: 'success'
								});
								this.$refs['editForm'].resetFields();
								this.editFormVisible = false;
								this.getArticles();
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
				      console.log("add papa=", para, this.addForm);
							this.myp.addItem(para, this.$router.token).then((res) => {
								this.addLoading = false;
								//NProgress.done();
								this.$message({
									message: 'success',
									type: 'success'
								});
								this.$refs['addForm'].resetFields();
								this.addFormVisible = false;
								this.getTags();
							});
						});
					}
				});
			},
			selsChange: function (sels) {
				this.sels = sels;
			},
			sortChange: function (obj) {
				console.log("sort change(c,p,o)=",obj.column, obj.prop, obj.order)
				this.sort_obj = obj
				this.getTags();
			}
		},
		mounted() {

			this.getTags();

		}
	}

</script>

<style scoped>

</style>