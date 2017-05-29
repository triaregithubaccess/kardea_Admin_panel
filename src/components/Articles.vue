<template lang="pug">
	section
		el-col.toolbar(:span='24', style='padding-bottom: 0px;')
			el-form(:inline='true', :model='filters')
				el-form-item
					el-input(v-model='filters.name', placeholder='article name')
				el-form-item
					el-button(type='primary', v-on:click='getArticles') Search
				el-form-item
					el-button(type='primary',  @click='handleAdd') Add new Article
		el-table(:data='articles', highlight-current-row='',
				v-loading='listLoading',
				@selection-change='selsChange',
				@sort-change='sortChange',

				style='width: 100%;')
			el-table-column(type='expand', width='55')
				template( scope="props")
					p
						b Abstract :
						|  {{ props.row.abstract }}
					p
						b Full Text :
						|  {{ props.row.full_text }}
					p
						b Source :
						|  {{ props.row.source }}
					p
						b Tags :
						|  {{ props.row.tags }}
			//el-table-column(prop='_id', label='ID', width='200', sortable='')

			el-table-column(v-if='che_id == undefined', prop='channel_name', label='Channel', width='150', sortable='')
			el-table-column(prop='headline', label='Headline', width='150', sortable='')
			el-table-column(prop='subtitle', label='Subtitle', width='150', sortable='')
			el-table-column(prop='source_name' label='Source name', width='150', sortable='')
			el-table-column(label='Source', width='300', sortable='')
				template( scope="scope")
					a(:href="scope.row.source", target="_blank") {{scope.row.source}}

			el-table-column(prop='language', label='Lang', width='80')
			el-table-column(label='Picture')
				template( scope="scope")
					img(:src="scope.row.picture   + '?width=100&height=100'")
			el-table-column(v-if='che_id == undefined', prop='updated_at', label='Updated at', wi-dth='150', sortable='', :formatter='formatDate')
			el-table-column(v-if='che_id == undefined', prop='created_at', label='Created at', wid-th='150', sortable='', :formatter='formatDate')
			el-table-column(label='Edit', width='150')
				template(scope='scope')
					el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
					el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
		el-col.toolbar(:span='24')
			el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
		// Edit
		el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
			el-form(:model='editForm', label-width='80px', :rules='editFormRules', ref='editForm')
				el-form-item(label='Headline', prop='headline')
					el-input(v-model='editForm.headline', auto-complete='off')
				el-form-item(label='Subtitle', prop='subtitle')
					el-input( v-model='editForm.subtitle', auto-complete='off')
				el-form-item(label='Abstract', prop='abstract')
					el-input(type="textarea" , v-model='editForm.abstract', auto-complete='off')
				el-form-item(label='Full text', prop='full_text')
					el-input(type="textarea" , v-model='editForm.full_text', auto-complete='off')
				el-col( :span="11")
					el-form-item(label='Channel')
						el-select(type='year', placeholder='channel', v-model='editForm.channel_id')
							el-option(v-for="che in  channels", :key="che._id", :label="che.title", :value="che._id")
				el-col( :span="11")
					el-form-item(label='Language')
						el-select(type='year', placeholder='language', v-model='editForm.language')
							el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
				el-form-item(label='Picture')
					el-upload(class="avatar-uploader",label='Picture',
					  :action="upload_url",
				  :show-file-list="false",
				  :on-success="handlePictureSuccess" ,
				  :before-upload="beforePictureUpload")
					img( v-if="editForm.picture", :src="editForm.picture", class="avatar")
					i( v-else class="el-icon-plus avatar-uploader-icon")
				el-form-item(label='Tags', props='tags')
					viewtags(:dynamicTags='editForm.tags')

			.dialog-footer(slot='footer')
				el-button(@click.native='editFormVisible = false') Cancel
				el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
		// Create Interface
		el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false')
			el-form(:model='addForm', label-width='80px', :rules='addFormRules', ref='addForm')
				el-form-item(label='Headline', prop='headline')
					el-input(v-model='addForm.headline', auto-complete='off')
				el-form-item(label='Subtitle', prop='subtitle')
					el-input(v-model='addForm.subtitle', auto-complete='off')
				el-form-item(label='Description', prop='description')
					el-input(type="textarea" , v-model='addForm.description', auto-complete='off')
				el-form-item(label='Picture')
					el-upload(class="avatar-uploader",
						:action="upload_url",
						:show-file-list="false",
						:on-success="handlePictureSuccess" ,
						:before-upload="beforePictureUpload")
						img( v-if="addForm.picture", :src="addForm.picture", class="avatar")
						i( v-else class="el-icon-plus avatar-uploader-icon")
				el-form-item(label='Channel')
					el-select(type='year', placeholder='channel', v-model='addForm.channel_id')
						el-option(v-for="che in channels", :key="che._id", :label="che.title", :value="che._id")

				el-form-item(label='Language')
					el-select(type='year', placeholder='language', v-model='addForm.language')
						el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
			.dialog-footer(slot='footer')
				el-button(@click.native='addFormVisible = false') Cancel
				el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
	import util from '../common/js/util'
	import _ from 'lodash'
	//import NProgress from 'nprogress'
	import { getArticleListPage,getChannelListPage, getArticleListPageByChe, removeArticle, editArticle, addArticle,  api_domen, image_upload_url2 } from '../api/api';
  import dtags from './Tags'
	export default {
		props: ["che_id"],
		components:
			{
				'viewtags': dtags
			},
	data() {
			return {
				upload_url: image_upload_url2,
				sort_obj: null,
				langs:  [
					{
					value: 'de',
					label: 'DE'
					},
					{
					value: 'en',
					label: 'EN'
					},
					],
			  filters: {
					name: ''
				},
				articles: [],
				channels: [],
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
					headline: '',
					abstract: '',
					description: '',
					picture: '',
					channel_id: '',
					tags: [],
					iuu: image_upload_url2
				},

				addFormVisible: false,
				addLoading: false,
				addFormRules: {
					name: [
						{ required: true, message: 'Title is required!', trigger: 'blur' }
					]
				},

				addForm: {
					headline: '',
					subtitle: '',
					description: '',
					language: '',
					channel_id: '',
					picture: ''
				}

			}
		},
		methods: {
			handlePictureSuccess(file, fileList) {
		  console.log(' Success pic!!');
				this.editForm.picture = api_domen + file.result
			},
			handlePictureSuccessAdd(file, fileList) {
		  console.log(' Success pic!!');
				this.addForm.picture = api_domen + file.result
			},
			beforePictureUpload(file) {
				console.log(file);
			},



			handleCurrentChange(val) {
				this.page = val;
				this.getArticles();
			},
			formatDate: function (row, column) {
				let cur = new Date(row[column.property]);
				return util.formatDate.format(cur, 'yyyy-MM-dd hh:mm:ss');
			},

			//Get the article list
			getArticles() {
				let get_func;
				let para2 = {};
				if (this.che_id == undefined) {
					para2 = {
						page: this.page,
						per_page: this.per_page_const,
						name: this.filters.name,
						token: this.$router.token
					};
					get_func = getArticleListPage;

				}else{

					para2 = {
						page: this.page,
						per_page: this.per_page_const,
						name: this.filters.name,
						che_id: this.che_id,
						token: this.$router.token
					};
					get_func = getArticleListPageByChe;
				}
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

				get_func(para2).then((res) => {
					this.total = res.data.count;
					this.articles = res.data.result;
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
					removeArticle(para).then((res) => {
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
							this.getArticles();
						}
					});
				}).catch(() => {

				});
			},
			// Edit
			handleEdit: function (index, row) {
				this.editFormVisible = true;
				this.getChannels();
				this.editForm = Object.assign({}, row);
			},
			// Create
			handleAdd: function () {
				this.addFormVisible = true;
		this.getChannels();

				this.addForm = {
					headline: '',
					subtitle: '',
					description: '',
					picture: '',
					channel_id: '',
					language: ''
				};
		if (this.che_id != null) {
					this.addForm.channel_id = this.che_id;
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
							let che = _.find(this.channels, (x) =>{ return x._id == para.channel_id })
							if (che !=  null) { para.channel_name = che.title; }

							editArticle(para, this.$router.token).then((res) => {
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
			getChannels: function () {
				let para = { };
		console.log("in get  Che");
				getChannelListPage(para, this.$router.token).then((res) => {
					this.channels = res.data.result;
		  console.log("resp che=", this.channels.length);
				}).catch((err) => {console.log("in catch  ggg", err);} );
			},

			//
			addSubmit: function () {
				this.$refs.addForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure？', 'warning', {}).then(() => {
							this.addLoading = true;
							//NProgress.start();
							let para = Object.assign({}, this.addForm);
						// find channel by id and get title
						let che = _.find(this.channels, (x) =>{ return x._id == para.channel_id })
					  if (che !=  null) { para.channel_name = che.title; }
							addArticle(para, this.$router.token).then((res) => {
								this.addLoading = false;
								//NProgress.done();
								this.$message({
									message: 'success',
									type: 'success'
								});
								this.$refs['addForm'].resetFields();
								this.addFormVisible = false;
								this.getArticles();
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
				this.getArticles();
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
					batchRemoveArticle(para).then((res) => {
						this.listLoading = false;
						//NProgress.done();
						this.$message({
							message: 'successfully deleted',
							type: 'success'
						});
						this.getArticles();
					});
				}).catch(() => {

				});
			}
		},
		mounted() {
			console.log("my-props=", this.che_id);
			this.getArticles();
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