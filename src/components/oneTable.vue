<template lang="pug">
  section
    el-col.toolbar(:span='21', style='padding-bottom: 10px;')
      el-form(:inline='true', :model='filters')
        el-form-item
          el-input(v-model='filters.name', :placeholder='myp.name_t_ph')
        el-form-item
          el-button(type='primary', v-on:click='getItems' ) Search
        el-form-item
          el-button(type='primary', @click='handleAdd') Add new
        el-select.left5( v-model="languages", v-if="myp.need_lang" )
          el-option(v-for="item in a_options", :key="item.value" , :label="item.label" , :value="item.value")

    el-col(:span="21")
      h3 {{myp.name_t}}
      el-table(:data='items', highlight-current-row='',
      v-loading='listLoading',
      @selection-change='selsChange',
      @sort-change='sortChange',

      style='width: 100%;')

        el-table-column(:prop='myp.f1', :label='myp.f1', wid-th='250', sortable='')
        el-table-column(prop='language', label='Lang', width='80', v-if="myp.need_lang")
        el-table-column(label='Edit', width='150')
          template(scope='scope')
            el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
            el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete

    el-col.toolbar(:span='21')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:left;')
      // Edit
      el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false')
        el-form(:model='editForm', label-width='80px', :rules='formRules',  ref='editForm')
          el-form-item(:label='myp.f1_caps',width='250', :prop='myp.f1')
            el-input(v-model='editForm[myp.f1]', auto-complete='off')
          el-form-item(label='Language', prop='language', v-if="myp.need_lang")
            el-select(type='year', placeholder='language', v-model='editForm.language')
              el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")

        .dialog-footer(slot='footer')
          el-button(@click.native='editFormVisible = false') Cancel
          el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
      // Create Interface
      el-dialog(title='New',size='tiny', v-model='addFormVisible', :close-on-click-modal='false')
        el-form(:model='addForm', label-width='80px', :rules='formRules',  ref='addForm')
          el-form-item(:label='myp.f1_caps', :prop='myp.f1')
            el-input(v-model='addForm[myp.f1]', auto-complete='off')
          el-form-item(label='Language', prop='language', v-if="myp.need_lang")
            el-select(type='year', placeholder='language', v-model='addForm.language')
              el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")

        .dialog-footer(slot='footer')
          el-button(@click.native='addFormVisible = false') Cancel
          el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
	import util from '../common/js/util'
	import _ from 'lodash'

	export default {
		props: ['myp'],
    watch: {
      'languages': function () {
        this.getItems();
      }
    },

    data() {
      var nonEmptyAndRequired = (rule, value, callback) => {
        if (value == undefined || value.trim() === '' ) {
          callback(new Error('Empty not allowed!'));
        } else {
          callback();
        }
      };

      let form_obj = {
        language: ''
      };
      form_obj[this.myp.f1] = '';

      let formRules = {};
      formRules[this.myp.f1]  = [ { required: true, validator: nonEmptyAndRequired, message: 'Please input '+ this.myp.f1, trigger: 'blur' } ]
      let filters = {};
      filters[this.myp.f1] = '';

      return {
				filters: filters,
				sort_obj: null,
	      items: [],
				total: 0,

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
            label: 'DE'
          },
          {
            value: 'en',
            label: 'EN'
          },
        ],

        page: 1,
				per_page_const: 14,
				listLoading: false,
				sels: [],

				editFormVisible: false,
				editLoading: false,

        addForm: form_obj,
				editForm: form_obj,
        formRules: formRules,

				addFormVisible: false,
				addLoading: false
			}
		},
		methods: {

			handleCurrentChange(val) {
				this.page = val;
				this.getItems();
			},
      get_lang() {
        if (this.languages == 'de,en') { return ''
        }else{ return this.languages }
      },

      //Get the Tag list
      getItems() {
				let para2 = {
						page: this.page,
						per_page: this.per_page_const,
						search: this.filters.name,
            language: this.languages,
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

				this.listLoading = true;

        this.myp.getList(para2).then((res) => {
          this.total = res.data.count;
          this.items = res.data.result;
          this.listLoading = false;
				}).catch((err) => {console.log("in catch ggg", err);} );
			},
			//  delete
			handleDel: function (index, row) {
				this.$confirm('Are you sure you want to delete the record?', 'warning', {
					type: 'warning'
				}).then(() => {
					this.listLoading = true;
					let para = { _id: row._id};
          this.myp.removeItem(para, this.$router.token).then((res) => {
						let meta = res.data.meta;
            if (meta.code != 200) {
							this.listLoading = false;
							this.$message({
								message: 'something wrong!',
								type: 'error'
							});
						}else {
							this.listLoading = false;
							this.$message({
								message: 'successfully  deleted',
								type: 'success'
							});
							this.getItems();
						}
					});
				}).catch(() => {

				});
			},
			// Edit
			handleEdit: function (index, row) {
				this.editFormVisible = true;
				this.getItems();
				this.editForm = Object.assign({}, row);
			},
			// Create
			handleAdd: function () {
			  console.log("in add handle");
				this.addFormVisible = true;
        this.getItems();

				//this.addForm = {};
				this.addForm[this.myp.f1] = '';
        //if (this.myp.need_lang) {
        this.addForm.language = this.get_lang();
        //}
			},
			// Edit save
			editSubmit: function () {
				this.$refs.editForm.validate((valid) => {
					if (valid) {
						this.$confirm('Are you sure ', 'warning', {}).then(() => {
							this.editLoading = true;
							let para = Object.assign({}, this.editForm);
							// trim text!!!
              para[this.myp.f1] = para[this.myp.f1].trim();
              this.myp.editItem(para, this.$router.token).then((res) => {
								this.editLoading = false;
								this.$message({
									message: 'Submitted successfully',
									type: 'success'
								});
								this.$refs['editForm'].resetFields();
								this.editFormVisible = false;
                this.getItems();
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
							let para = Object.assign({}, this.addForm);
              // trim text!!!
              para[this.myp.f1] = para[this.myp.f1].trim();

							this.myp.addItem(para, this.$router.token).then((res) => {
								this.addLoading = false;
								this.$message({
									message: 'success',
									type: 'success'
								});
								this.$refs['addForm'].resetFields();
								this.addFormVisible = false;
								this.getItems();
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
				this.getItems();
			}
		},
		mounted() {
			this.getItems();

		}
	}

</script>

<style scoped>
.el-form-item {
  margin-bottom: 20px;
}

</style>