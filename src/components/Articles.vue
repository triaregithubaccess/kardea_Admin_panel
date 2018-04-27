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
        el-select.left5( v-model="languages", v-show="che_id == undefined")
          el-option(v-for="item in a_options",
          :key="item.value" ,
          :label="item.label" ,
          :value="item.value")

    el-table(:data='articles', highlight-current-row='',
        v-loading='listLoading',
        @selection-change='selsChange',
        @row-click='handleRowClick',
        @sort-change='sortChange',
        @expand="exp",
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
          p
            //el-table(:data='tmpcom', style='width: 100%;')
            //el-table(:data='[{name: props.row._id, cou: "33 comments"+props.row._id},{name: props.row._id, cou: "313 comments"+props.row._id}]', style='width: 100%;')
              el-table-column(type='expand', label='Comments')
                template( )
                  |comments(:news_id='props.row._id')
              el-table-column(prop='cou', label='Comments')
            el-table(:data='tmpcom', style='width: 100%;')
              el-table-column(type='expand', label='Comments')
                template( )
                  comments(:news_id='cur_news')
              el-table-column(prop='cou', label='Comments')
      //el-table-column(prop='_id', label='ID', width='200', sortable='')

      el-table-column(v-if='che_id == undefined', prop='channel_name', label='Topic', width='150', sortable='')
      el-table-column(prop='headline', label='Headline', width='150', sortable='')
      el-table-column(prop='subtitle', label='Subtitle', width='150', sortable='')
      el-table-column(v-if='che_id == undefined && pre', prop='published_at', label='Published at', width='200', sortable='', :formatter='formatDate')
      el-table-column(v-if='!pre', prop='source_name', label='Source name', width='150', sortable='')
      el-table-column(v-if='!pre', label='Source', width='300', sortable='')
        template( scope="scope")
          a(:href="scope.row.source", target="_blank") {{scope.row.source}}

      el-table-column(prop='language', label='Lang', width='80')
      el-table-column(label='Picture', width='110')
        template( scope="scope")
          img( v-if="is_our(scope.row.picture)" ,:src="scope.row.picture   + '?width=100&height=100'", class="avatar100")
          img( v-else,:src="scope.row.picture", class="avatar100")
      el-table-column(v-if='!pre', label='WordPress', width='200', sortable='')
        template( scope="scope")
          a(:href="scope.row.wp_link", target="_blank") {{scope.row.wp_link}}
      el-table-column(v-if='che_id == undefined', prop='updated_at', label='Updated at', width='200', sortable='', :formatter='formatDate')
      el-table-column(v-if='che_id == undefined', prop='created_at', label='Created at', width='200', sortable='', :formatter='formatDate')
      el-table-column(label='Edit', width='150')
        template(scope='scope')
          el-button(size='small', @click='handleEdit(scope.$index, scope.row)') Edit
          el-button(type='danger', size='small', @click='handleDel(scope.$index, scope.row)') delete
    el-col.toolbar(:span='24')
      el-pagination(layout='prev, pager, next', @current-change='handleCurrentChange', :page-size='per_page_const', :total='total', style='float:right;')
    // Edit
    el-dialog(title='Edit', v-model='editFormVisible', :close-on-click-modal='false', size="large")
      el-form(:model='editForm', label-width='80px', :rules='formRules', ref='editForm')
        el-row(:span="23")

          el-col( :span="11")
            el-form-item(label='Headline', prop='headline')
              el-input(v-model='editForm.headline', auto-complete='off')
            el-form-item(label='Subtitle', prop='subtitle')
              el-input( v-model='editForm.subtitle', auto-complete='off')
            el-form-item(label='Abstract', prop='abstract')
              el-input(type="textarea" , v-model='editForm.abstract', auto-complete='off')
            el-form-item(label='Source Name', prop='source_name')
              el-input(v-model='editForm.source_name', auto-complete='off')
            el-form-item(label='Source', prop='source')
              el-input(v-model='editForm.source', auto-complete='off', placeholder='http://site.com')
            el-form-item(label='WordPress', prop='source')
              el-input(v-model='editForm.wp_link', auto-complete='off', placeholder='http://site.com')
            el-row(:span="23")
              el-col( :span="11")
                el-form-item(label='Topic', prop='channel_id')
                  el-select(type='year', placeholder='topic', v-model='editForm.channel_id')
                    el-option(v-for="che in  channels", :key="che._id", :label="che.title", :value="che._id")
              el-col( :span="11")
                el-form-item(label='Language', prop='language', v-show="che_id == undefined")
                  el-select(type='year', placeholder='language', v-model='editForm.language')
                    el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
            el-form-item(label='Picture', prop='picture')
              el-upload(class="avatar-uploader",label='Picture',
                :action="upload_url",
                :show-file-list="false",
                :on-success="handlePictureSuccess" ,
                :before-upload="beforePictureUpload")
                img( v-if="editForm.picture", :src="editForm.picture", class="avatar")
                i( v-else class="el-icon-plus avatar-uploader-icon")
            el-form-item(label='Tags',  props='tags')
              viewtags(:dynamicTags='editForm.tags', ref='editTagList', :lang="languages")
            el-form-item(label='Internal Tags', props='internal_tags')
              viewtags(:dynamicTags='editForm.internal_tags',  ref='editIntTagList', :internal="true")

            el-form-item(label='Publish at', prop='published_at')
              el-date-picker(v-model='editForm.published_at',type="datetime",placeholder="If empty - live now", :disabled="!pre")
            el-col( :span="5")
              el-form-item(label='Push', prop='push_on_publish')
                el-checkbox( v-model='editForm.push_on_publish')
            el-col( :span="5")
              el-form-item(label='To Site', prop='site_on_publish')
                el-checkbox( v-model='editForm.site_on_publish', :disabled='editForm.desss')
            el-col( :span="5")
              el-form-item(label='To FB', prop='fb_on_publish')
                el-checkbox( v-model='editForm.fb_on_publish', disabled)


          el-col( :span="8", :offset="2")
            el-form-item(label='Full text', prop='full_text')
              .el-form-item(id="addB")
                .grey Optimal size: under 5 Mb and Aspect ration: 3x2
                el-upload(class="editor-uploader",
                :action="upload_url",
                :show-file-list="false",
                :on-success="handlePictureSuccessEditorEdit" ,
                :before-upload="beforePictureUpload")
                  el-button(type='primary') Upload picture
              editor( :text2="editForm.full_text", @editor_changed='handle_editor_changed_edit',  ref='to_editor_edit', e_id="edit_mce")

      .dialog-footer(slot='footer')
        el-button(@click.native='editFormVisible = false') Cancel
        el-button(type='primary', @click.native='editSubmit', :loading='editLoading') Submit
    // Create Interface
    el-dialog(title='New', v-model='addFormVisible', :close-on-click-modal='false', size="large")
      el-form(:model='addForm', label-width='80px', :rules='formRules', ref='addForm')
        el-row(:span="23")

          el-col( :span="11")
            el-form-item(label='Headline', prop='headline')
              el-input(v-model='addForm.headline', auto-complete='off')
            el-form-item(label='Subtitle', prop='subtitle')
              el-input(v-model='addForm.subtitle', auto-complete='off')
            el-form-item(label='Abstract', prop='abstract')
              el-input(type="textarea" , v-model='addForm.abstract', auto-complete='off')

            el-form-item(label='Source Name', prop='source_name')
              el-input(v-model='addForm.source_name', auto-complete='off')
            el-form-item(label='Source', prop='source')
              el-input(v-model='addForm.source', auto-complete='off', placeholder='http://site.com')

            el-row(:span="23")
              el-col( :span="11")
                el-form-item(label='Topic', prop='channel_id')
                  el-select(type='year', placeholder='topic', v-model='addForm.channel_id', :disabled='languages == "de,en" ? true: false')
                    el-option(v-for="che in channels", :key="che._id", :label="che.title", :value="che._id")
              el-col( :span="11")
                el-form-item(label='Language', prop='language')
                  el-select(type='year', placeholder='language', v-model='addForm.language' , :disabled="che_id != undefined? true: false")
                    el-option(v-for="lang in langs", :key="lang.value", :label="lang.label", :value="lang.value")
            el-form-item(label='Picture', prop='picture')
              .grey Optimal size: under 5 Mb
              el-upload(class="avatar-uploader",label='Picture',
                :action="upload_url",
                :show-file-list="false",
                :on-success="handlePictureSuccessAdd" ,
                :before-upload="beforePictureUpload")
                img( v-if="addForm.picture", :src="addForm.picture", class="avatar")
                i( v-else class="el-icon-plus  avatar-uploader-icon")

            el-form-item(label='Tags', props='tags')
              viewtags(:dynamicTags='addForm.tags',  ref='addTagList', :dis='languages == "de,en" ? (che_id == undefined? true: false): false', :lang="languages")
            el-form-item(label='Internal Tags', props='internal_tags')
              viewtags(:dynamicTags='addForm.internal_tags',  ref='addIntTagList', :internal="true")
            el-form-item(label='Publish at', prop='published_at')
              el-date-picker(v-model='addForm.published_at',type="datetime",placeholder="If empty - live now")
            el-col( :span="5")
              el-form-item(label='Push', prop='push_on_publish')
                el-checkbox( v-model='addForm.push_on_publish')
            el-col( :span="5")
              el-form-item(label='To Site', prop='site_on_publish')
                el-checkbox( v-model='addForm.site_on_publish')
            el-col( :span="5")
              el-form-item(label='To FB', prop='fb_on_publish')
                el-checkbox( v-model='addForm.fb_on_publish', disabled)
          el-col( :span="8", :offset="2")
            el-form-item(label='Full text', prop='full_text')
              .el-form-item(id="addB")
                .grey Optimal size: under 5 Mb and Aspect ration: 3x2
                el-upload(class="editor-uploader",
                :action="upload_url",
                :show-file-list="false",
                :on-success="handlePictureSuccessEditorAdd" ,
                :before-upload="beforePictureUpload")
                  el-button(type='primary') Upload picture
              editor( :text2="addForm.full_text", @editor_changed='handle_editor_changed_add',  ref='to_editor_add', e_id="add_mce")

      .dialog-footer(slot='footer')
        el-button(@click.native='addFormVisible = false') Cancel
        el-button(type='primary', @click.native='addSubmit', :loading='addLoading') Create

</template>

<script >
  import util from '../common/js/util'
  import _ from 'lodash'
  //import NProgress from 'nprogress'
  import { getArticleListPage,getChannelListPage, getArticleListPageByChe, getChannelShortListPage,removeArticle, editArticle, addArticle,  api_domen, image_upload_url2 } from '../api/api';
  import dtags from './Tags'
  import commentsList from './Comments'
  import tmc from '../views/components/tinymce'

  let init_state = function() {
    return {
    headline: '',
    subtitle: '',
    abstract: '',
    picture: '',
    channel_id: '',
    language: '',
    full_text: '',
    source: '',
    source_name: '',
    published_at: '',
    tags: [],
    internal_tags: [],
    push_on_publish: '',
    site_on_publish: '',
    fb_on_publish: '',
    wp_link: '',
    desss: false,
    iuu: image_upload_url2
  }};

  export default {
    props: ["che_id","pre", "lang"],
    components:
      {
        viewtags: dtags,
        comments: commentsList,
        editor: tmc

      },
    watch: {
      'editForm.language': function (a,b) {
        //console.log("edit Form:a b", a,b, "---", a == '', b == '')
        if (this.editForm.language != '') {
          this.languages = this.editForm.language
        }


        if (b != '') {
          this.editForm.channel_id = '';
          this.editForm.tags = [];
          this.editForm.internal_tags = [];
        }
        this.getChannels();
      },
      'addForm.language': function () {
        this.languages = this.addForm.language
        if (this.che_id != null){
          'nope'
        }else {
          this.addForm.channel_id = '';
        }
        this.addForm.tags.splice(0)
        this.addForm.internal_tags.splice(0)
        this.getChannels();
      },
      'languages': function () {
        this.getArticles();
      },
      'editFormVisible': function (a,b) {
        //console.log("edit FormVi:a b", a,b)
        if (a){}else{
          //console.log("set false", a)
          this.editForm.language = '';
        }

      },
//      'che_id': function () {
//        this.addForm.channel_id = '';
//      },
      '$route' (toto, from) {
        //console.log("to from", toto, from);
        if (toto.name == "Articles") {
          this.pre = false
          this.getArticles()
        }
        if (toto.name == "Pre Articles") {
          this.pre = true
          this.getArticles()
        }

//        if (this.$route.params.category) {
//          this.loadArticles(category);
//        } else {
//          this.loadArticles();
//        }
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

      return {
        upload_url: image_upload_url2,
        sort_obj: null,
        //tmpcom: [{name: "total 48 comments"}],
        tmpcom: [{name: 'ggg', cou: " comments"}],
        cur_news: '',

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
        filters: {
          name: ''
        },
        articles: [],
        channels: [],
        total: 0,
        page: 1,
        per_page_const:  10,
        listLoading: false,
        sels: [],//selected rows

        editFormVisible: false,
        editLoading: false,

        formRules: {
          headline: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Headline', trigger: 'blur' } ] ,
          subtitle: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Subtitle', trigger: 'blur' } ] ,
          abstract: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Abstract', trigger: 'blur' } ] ,
          full_text: [ { required: true,validator: nonEmptyAndRequired, message: 'Please input Text', trigger: 'blur' } ] ,
          channel_id: [ { required: true, message: 'Please choose Topic', trigger: 'blur' } ] ,
          language: [ { required: true, message: 'Please input Language', trigger: 'blur' } ],
          picture: [ { required: true, message: 'Please upload Picture', trigger: 'blur' } ],
        },
        // Edit
        editForm: init_state(),

        addFormVisible: false,
        addLoading: false,
        addFormRules: {
          name: [
            { required: true, message: 'Title is required!', trigger: 'blur' }
          ]
        },

        addForm: init_state(),

      }
    },
    methods: {
      handle_editor_changed_add(xx) {
        //console.log('in add art new full_text:',xx)
        this.addForm.full_text = xx;
      } ,
      handle_editor_changed_edit(xx) {
        //console.log('in edit art new full_text:',xx)
        this.editForm.full_text = xx;
      } ,


      get_lang() {
        if (this.languages == 'de,en') { return ''
        }else{ return this.languages }
      },
      handlePictureSuccess(file, fileList) {
//        console.log(' Success pic!!');
        this.editForm.picture = api_domen + file.result
      },
      handlePictureSuccessAdd(file, fileList) {
//        console.log(' Success pic!!');
        this.addForm.picture = api_domen + file.result
      },
      beforePictureUpload(file) {
//        console.log(file);
      },
      gettmpcom(x) {
//        console.log('in get gggggg');
        let g = [{cou: '34 com-ts', name: x}];
        return g
      },
      exp(a,b){
        this.cur_news = a._id
      },

      handleCurrentChange(val) {
        this.page = val;
        this.getArticles();
      },
      formatDate: function (row, column) {
        let cur = new Date(row[column.property]);
        return util.formatDate.format(cur, 'yyyy-MM-dd hh:mm:ss');
      },
      handlePictureSuccessEditorAdd(file, fileList) {
        const uid = '1234567890'
        let new_img_url = api_domen + file.result
        let new_img = {
          hasSuccess: true,
          uid:  1508615239083,
          width: 222,
          height: 222,
          url: new_img_url
        }
        this.$emit('successCBK', [new_img])
        this.$refs.to_editor_add.imageSuccessCBK222([new_img]);

      },
      handlePictureSuccessEditorEdit(file, fileList) {
        const uid = '1234567890'
        let new_img_url = api_domen + file.result
        let new_img = {
          hasSuccess: true,
          uid:  1508615239083,
          width: 222,
          height: 222,
          url: new_img_url
        }
        this.$emit('successCBK', [new_img])
        this.$refs.to_editor_edit.imageSuccessCBK222([new_img]);

      },

      //Get the article list
      getArticles() {
        //console.log("in get A")
        let get_func;
        let para2 = {};
        if (this.che_id == undefined) {
          para2 = {
            page: this.page,
            pre: this.pre,
            per_page: this.per_page_const,
            name: this.filters.name,
            language: this.languages,
            token: this.$router.token
          };
          get_func = getArticleListPage;

        }else{

          para2 = {
            page: this.page,
            per_page: this.per_page_const,
            name: this.filters.name,
            che_id: this.che_id,
            language: this.lang,
            token: this.$router.token
          };
          //console.log(para2)
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

//        console.log("para2=", para2)
        this.listLoading = true;
        //NProgress.start();

        get_func(para2).then((res) => {
          this.total = res.data.count;
          this.articles = res.data.result;
          this.listLoading = false;
//          this.filters.name = ''
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
          let para = { _id: row._id, pre: this.pre};
          console.log(para)
          removeArticle(para, this.$router.token ).then((res) => {
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
        if (row.internal_tags == undefined) { row.internal_tags = [] }
        if (row.tags == undefined) { row.tags = [] }
        this.editForm.internal_tags = JSON.parse ( JSON.stringify(row.internal_tags) )
        this.editForm.tags = JSON.parse ( JSON.stringify(row.tags) )
        this.editForm.desss = this.editForm.site_on_publish

        this.$nextTick(() => { this.$refs.to_editor_edit.init_content(this.editForm.full_text)})
      },
      // Create
      handleAdd: function () {
        this.addForm['language'] =  this.get_lang();

        if (this.che_id != null) {
          this.addForm.channel_id = this.che_id;
          this.addForm.language = this.lang;

        } else {
          this.addForm.channel_id = ''

        }
        this.getChannels();
        this.addForm.tags = []
        this.addForm.internal_tags = []
        this.addFormVisible = true;
        this.$nextTick(() => {
          //console.log("Next tick")
          this.$refs.to_editor_add.init_content(this.addForm.full_text)});

      },
      // Edit save
      editSubmit: function () {
//        console.log("editSubmit....")
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
                //console.log('before call tags method', this.$refs);
                //this.$refs['editTagList'].getTags();
              });
            });
          }
        });
      },
      getChannels: function () {
        let para = {
          page: 1,
          per_page: 999,
          language: this.languages
        };
//        console.log("in get  Che");
        getChannelShortListPage(para, this.$router.token).then((res) => {
          this.channels = res.data.result;
//          console.log("resp che=", this.channels.length);
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
                this.$refs['addTagList'].getTags();
                //this.$refs['addIntTagList'].getTags('internal');
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

      is_our: function (url) {
        if (url == undefined) {
          return false
        }
        let str = url.substr(0,13)
        console.log(str)
        if (str == 'http://localh' || str == 'https://api.k'|| str == 'http://138.20') {
          return true
        }
        return false
      },
      selsChange: function (sels) {
        this.sels = sels;
      },
      sortChange: function (obj) {
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
      console.log("Art my-props=", this.che_id, this.pre);
      if (this.che_id != null){
        this.per_page_const = 5;
        this.addForm.channel_id = this.che_id
      }
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
.grey{
  color: #bfd9d0;
}
.avatar {
  width: 178px;
  height: 178px;
  display: block;
}
.avatar100 {
  width: 100px;
  height: 67px;
  display: block;
}

</style>