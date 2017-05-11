<template lang="pug">
	section
	  el-col.toolbar(:span='24', style='padding-bottom: 0px;')
	    el-form(:inline='true', :model='filters')
	      el-form-item
	        el-input(v-model='filters.name', placeholder='channel name')
	      el-form-item
	        el-button(type='primary', v-on:click='getChannels') Search
	      el-form-item
	        el-button(type='primary', @click='handleAdd') Add new Channel
	  el-table(:data='channels', highlight-current-row='', v-loading='listLoading', @selection-change='selsChange', style='width: 100%;')
	    el-table-column(type='expand', width='55')
	      template( scope="props")
	        p
	          b Description :
	          |  {{ props.row.description }}
	        article_list(:che_id='props.row._id')
	    //el-table-column(prop='_id', label='ID', width='200', sortable='')
	    el-table-column(prop='title', label='Title', width='200', sortable='')
	    el-table-column(label='Picture')
	      template( scope="scope")
	        img(:src="scope.row.picture   + '?width=100&height=100'")
	    el-table-column(label='Wide Pic')
	      template( scope="scope")
	        img(:src="scope.row.wide_picture   + '?width=150&height=150'")
	    el-table-column(prop='language', label='Lang', width='100',
	            :filters="langs",
	            :filter-method="filterLang",
	            filter-placement="bottom-end")
	      template( scope="scope")
	        el-tag(:type="scope.row.language === 'de' ? 'primary' : 'success' ", close-transition ) {{scope.row.language}}
	    el-table-column(prop='updated_at', label='Updated at', wi-dth='200', sortable='', :formatter='formatDate')
	    el-table-column(prop='created_at', label='Created at', wid-th='200', sortable='', :formatter='formatDate')
	    el-table-column(label='Edit', width='150')
	      template(scope='scope')
	        el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
	        el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
	  el-col.toolbar(:span='24')
	    el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
	  // Edit
	  el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
	    el-form(:model='editForm', label-width='80px', :rules='editFormRules', ref='editForm')
	      el-form-item(label='Title', prop='title')
	        el-input(v-model='editForm.title', auto-complete='off')
	      el-form-item(label='Description', prop='description')
	        el-input(type="textarea" , v-model='editForm.description', auto-complete='off')
	      el-form-item(label='Language')
	        el-select(type='year', placeholder='language', v-model='editForm.language')
	          el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")

	      el-upload(class="avatar-uploader",
	        :action="upload_url",
			:show-file-list="false",
			:on-success="handleAvatarSuccess" ,
			:before-upload="beforeAvatarUpload")
	        img( v-if="editForm.picture", :src="editForm.picture", class="avatar")
	        i( v-else class="el-icon-plus avatar-uploader-icon")


	    .dialog-footer(slot='footer')
	      el-button(@click.native='editFormVisible = false') Cancel
	      el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
	  // Create Interface
	  el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
	    el-form(:model='addForm', label-width='80px', :rules='addFormRules', ref='addForm')
	      el-form-item(label='Title', prop='title')
	        el-input(v-model='editForm.title', auto-complete='off')
	      el-form-item(label='Description', prop='description')
	        el-input(type="textarea" , v-model='editForm.description', auto-complete='off')
	      el-form-item(label='Language')
	        el-select(type='year', placeholder='language', v-model='editForm.language')
	          el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")

	      el-upload(class="avatar-uploader",
	        :action="upload_url",
	        :show-file-list="false",
	        :on-success="handleAvatarSuccess" ,
	        :before-upload="beforeAvatarUpload")
	        img( v-if="editForm.picture", :src="editForm.picture", class="avatar")
	        i( v-else class="el-icon-plus avatar-uploader-icon")
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
		data() {
			return {
				upload_url: image_upload_url2,
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
				per_page_const: 14,
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
					title: '',
					description: '',
					picture: '',
					wide_picture: '',
					iuu: image_upload_url2,
				},

				addFormVisible: false,
				addLoading: false,
				addFormRules: {
					name: [
						{ required: true, message: 'Title is required!', trigger: 'blur' }
					]
				},

				addForm: {
					title: '',
					description: '',
					picture: '',
					wide_picture: '',
				}

			}
		},
		methods: {
			handleAvatarSuccess(file, fileList) {
				this.editForm.picture = api_domen + file.result
			},
			beforeAvatarUpload(file) {
				console.log(file);
			},

			filterLang(value, row) {
				console.log("in Filter Langs", value, row);
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

			//Get the channel list
			getChannels() {
				let para = {
					page: this.page,
					per_page: this.per_page_const,
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
				    console.log("in DELETE:", this.$router.token, row._id, row);
					let para = { _id: row._id, token: this.$router.token };
					removeChannel(para).then((res) => {
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
							this.getChannels();
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
					title: '',
					description: '',
					picture: '',
					wide_picture: ''
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
							addChannel(para).then((res) => {
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

</style>