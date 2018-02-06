<template>
  <div class="components-container">
    <div>
      <tinymce :height='600' v-model="content" ref="ediTor" :id="e_id" :value="content" ></tinymce>
    </div>
    <!--<div class='editor-content' v-html='content'></div>-->
  </div>
</template>

<script>
import Tinymce from '../../components/Tinymce'
//console.log("In v/c/tinymce !")
export default {
  props:["text2","e_id"] ,
  watch: {
    'content': function (a,b) {
      //console.log("content in tmce changed!",b,'=>',a)
      this.$emit('editor_changed', String(this.content));
    },
    'text2': function (a,b) {
      //console.log("text2 in tmce  changed!", b,'=>',a)
      this.content =  this.text2
    }
  },
  components: { Tinymce },
  data() {
    return {
      content: this.text2,
    }
  },
  methods:{
    imageSuccessCBK222(arr){
      this.$refs.ediTor.imageSuccessCBK(arr);
    },
    init_content (val ){
      this.$refs.ediTor.init_content(val);
    }

  }
}
</script>

<style scoped>
.editor-content{
  margin-top: 20px;
}
</style>


