<template lang="pug">
  el-col( )
    el-tag( :key="tag",
      v-for="tag in dynamicTags",
      type="primary" ,
      hit=true,
      :closable="true",
      :close-transition="false" ,
      @close="handleClose(tag)") {{tag}}
    el-select( class="input-new-tag",
      v-model="inputValue",
      ref="saveTagInput",

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

    el-button( v-else, class="button-new-tag", size="small", @click="showInput") + New Tag
</template>

<script>
	import { getAllTags } from '../api/api';

  export default {
  	props: ['dynamicTags'],
    data() {
      return {
        inputVisible: false,
        inputValue: '',
        all_tags: []
      };
    },
    methods: {
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
				let para = { };
//        console.log("in get Tags");
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
.input-new-tag {
  margin-left: 10px; }
.button-new-tag {
  margin-left: 10px; }
.el-tag {
    margin-left: 10px; }

</style>