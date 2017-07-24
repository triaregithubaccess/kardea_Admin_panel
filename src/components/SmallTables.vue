<template lang="pug">
	section

		//el-row

		el-col(:span="9")
			onetable( :myp='tagApiService', name_t='TAGs', name_t_ph='tag name')

		el-col(:span="9")
			onetable( :myp='badwordApiService', name_t='Bad Words', name_t_ph='bad word')

		el-col.toolbar(:span='24')
			// el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
			// Edit
			el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
				el-form(:model='editForm', label-width='80px', :rules='editFormRules', ref='editForm')
					el-form-item(label='Name',width='250', prop='name')
						el-input(v-model='editForm.name', auto-complete='off')

				.dialog-footer(slot='footer')
					el-button(@click.native='editFormVisible = false') Cancel
					el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
			// Create Interface
			el-dialog(title='New',size='tiny', v-model='addFormVisible', :close-on-click-modal='false')
				el-form(:model='addForm', label-width='80px',  ref='addForm')
					el-form-item(label='Name', prop='name')
						el-input(v-model='addForm.name', auto-complete='off')

				.dialog-footer(slot='footer')
					el-button(@click.native='addFormVisible = false') Cancel
					el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
	import util from '../common/js/util'
	import _ from 'lodash'
	import { getTagListPage,  removeTag, editTag, addTag } from '../api/api';
	import { getBWListPage,   removeBW,  editBW,  addBW  } from '../api/api';

//  import NProgress from 'nprogress'
  import ot from './OneTable' ;

  let tagApiService = {
		getList: getTagListPage,
		addItem: addTag,
    editItem: editTag,
		removeItem: removeTag,
		f1: 'name'
	};

  let badwordApiService = {
		getList: getBWListPage,
		addItem: addBW ,
    editItem: editTag,
    removeItem: removeBW,
		f1: 'word'
	};

	export default {
	  components:
	    {
		    'onetable': ot
	     },

	  data() {
			return {
				tagApiService,
				badwordApiService,
				filters: {
					name: ''
				},
				tags:[],
				sort_obj: null,
				total: 0,
				page: 1,
				per_page_const: 4,
				listLoading: false,
				sels: [],//selected rows

				editFormVisible: false,
				editLoading: false,
				editFormRules: {
					title: [
						{ required: true, message: 'Please type title', trigger: 'blur' }
					]
				},
				// Edit
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

			temp1() {console.log(111)},

			handleCurrentChange(val) {
				this.page = val;
				this.getTags();
			},

			//Get the Tag list
			get_Tags() {
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

//				console.log("para2=", para2)
				this.listLoading = true;
				//NProgress.start();

        getListPage(para2).then((res) => {
					this.total = res.data.count;
					this.tags = res.data.result;
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
//				    console.log("in DELETE:", this.$router.token, row._id, row);
					let para = { _id: row._id, token: this.$router.token };
					removeTag(para).then((res) => {
						let meta = res.data.meta;
//						console.log("meta and res",meta, res)
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
				this.addFormVisible = true;
        this.getTags();

				this.addForm = {
					name: ''
				};

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

							addTag(para, this.$router.token).then((res) => {
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
//				console.log("sort change(c,p,o)=",obj.column, obj.prop, obj.order)
				this.sort_obj = obj
				this.getTags();
			}
		},
		mounted() {
//		    console.log("my-props=", this.che_id);
			//this.getTags();
		}
	}

</script>

<style scoped>

</style>