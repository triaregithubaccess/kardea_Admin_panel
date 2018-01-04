<template lang="pug">
  el-col( )
    <!--el-transfer( filterable,-->
      <!--:filter-method="filterMethod",-->
      <!--filter-placeholder="State Abbreviations",-->
      <!--:titles="['Source', 'Target']",-->
      <!--v-model="dynamicTags",-->
      <!--:data="dis2")-->


    el-tag( :key="tag",
      v-for="tag in dynamicTags",
      type="primary" ,
      :disabled="dis" ,
      hit=true,
      :closable="true",
      :close-transition="false" ,
      @close="handleClose(tag)") {{tag}}
    el-select( class="input-new-tag",
      v-model="inputValue",
      ref="saveTagInput",
      :disabled="dis"
      @keyup.enter.native="handleInputConfirm",
      @blur="handleInputConfirm"
      filterable,

      @change='handleInputConfirm()',
      allow-create,
      v-if="inputVisible")
      el-option( v-for="item in all_tags",
        :key="item" ,

        :label="item" ,
        :value="item")

    el-button( v-else, class="button-new-tag", size="small", @click="showInput", :disabled="dis") + New Tag
</template>

<script>
	import { getAllTags } from '../api/api';

  export default {
  	props: ['dynamicTags', 'dis', 'lang', 'internal'],
    watch: {

      'lang': function () {
        this.getTags();
      }
    },




    data() {
      return {
        dis2: this.generateData2(),
        inputVisible: false,
        inputValue: '',
        all_tags: []
      };
    },
    methods: {
      filterMethod(query, item) {
        return item.initial.toLowerCase().indexOf(query.toLowerCase()) > -1;
      },
      generateData2() {
        const data = [];
        const states = ['California', 'Illinois', 'Maryland', 'Texas', 'Florida', 'Colorado', 'Connecticut '];
        const initials = ['CA', 'IL', 'MD', 'TX', 'FL', 'CO', 'CT'];
        states.forEach((city, index) => {
          data.push({
            label: city,
            key: index,
            initial: initials[index]
          });
        });
        return data;
      },



  get_lang() {
        return this.lang
//        if (this.languages == 'de,en') { return ''
//        }else{ return this.languages }
      },
      handleClose(tag) {
        this.dynamicTags.splice(this.dynamicTags.indexOf(tag), 1);
      },

      showInput() {
        this.inputVisible = true;
        this.$nextTick(_ => {
          //console.log('in show input', this.all_tags);
          this.$refs.saveTagInput.$refs.reference.$refs.input.focus();
        });
      },

      handleInputConfirm() {
        //console.log("HIC-------", this.inputValue);
        let inputValue = this.inputValue;

        if (inputValue) {
          this.dynamicTags.push(inputValue);
        }
        this.inputVisible = false;
        this.inputValue = '';
      },

      getTags: function () {
        let kind
        if (this.internal) {
          kind = 'internal'
        } else{
          kind = 'EXTERNAL'
        }
				let para = {page:1, per_page:99999,language: this.get_lang(), kind: kind };
				getAllTags(para, this.$router.token).then((res) => {
					this.all_tags = res.data.result;
          //console.log("resp tags=", this.all_tags);
				}).catch((err) => {console.log("in catch  tags", err);} );
			}


    }  ,
    mounted() {
//      console.log("tag-props=", this.dynamicTags);
      this.getTags();
    }
  }
</script>


<style scoped>

.el-transfer-panel {
  border: 1px solid #d1dbe5;
  box-shadow: 0 2px 4px rgba(0,0,0,.12), 0 0 6px rgba(0,0,0,.04);
  display: inline-block;
  width: 200px;
  position: relative;
}

.el-checkbox-button__inner, .el-transfer-panel {
  background: #fff;
  vertical-align: middle;
  box-sizing: border-box;
}

.input-new-tag {
  margin-left: 10px; }
.button-new-tag {
  margin-left: 10px; }
.el-tag {
    margin-left: 10px; }

</style>