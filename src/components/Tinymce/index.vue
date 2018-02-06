<template  lang="pug">
  .tinymce-container.editor-container
    textarea.tinymce-textarea( :id="tinymceId")
</template>

<script>
import editorImage from './components/editorImage'

export default {
  name: 'tinymce',
  components: { editorImage },
  props: {
    id: {
      type: String
    },
    value: {
      type: String,
      default: ''
    },
    toolbar: {
      type: Array,
      required: false,
      default() {
        return ['media image undo redo bold italic underline numlist bullist']
      }
    },
    menubar: {
      default: ''
    },
    height: {
      type: Number,
      required: false,
      default: 360
    }
  },
  data() {
    return {
      hasChange: false,
      hasInit: false,
      tinymceId: this.id || 'vue-tinymce-' + +new Date()
    }
  },
  watch: {
    value(val) {
      //console.log('in editor index   --  val:',val)
      if (!this.hasChange && this.hasInit) {
        //console.log("in editor index - call set conten")
        this.$nextTick(() => window.tinymce.get(this.tinymceId).setContent(val))
      } //else{console.log("set Content do not called!!!!!!")}
    }
  },
  mounted() {
    const _this = this
    //console.log("TMCE INIT------------", this.tinymceId ,window.tinymce)
    window.tinymce.init({
      selector: `#${this.tinymceId}`,
      height: this.height,
      body_class: 'panel-body ',
      object_resizing: false,
      toolbar: this.toolbar,
      menubar: this.menubar,
      plugins: 'advlist,autolink,code,paste,textcolor, fullscreen,link,lists,media, imagetools,image, lists',
      end_container_on_empty_block: true,
      powerpaste_word_import: 'clean',
      code_dialog_height: 450,
      code_dialog_width: 1000,
      advlist_bullet_styles: 'square',
      advlist_number_styles: 'default',
      //block_formats: p or h2;',
      //imagetools_cors_hosts: ['wpimg.wallstcn.com', 'wallstreetcn.com'],
      imagetools_toolbar: 'image',

      default_link_target: '_blank',
      link_title: false,
      init_instance_callback: editor => {
        if (_this.value) {
          editor.setContent(_this.value)
        }
        _this.hasInit = true
        editor.on('NodeChange Change KeyUp', () => {
          this.hasChange = true
          this.$emit('input', editor.getContent({ format: 'raw' }))
        })
      },

      setup(editor) {
//        editor.addButton('h2', {
//          title: 'subtitle', // tooltip text seen on mouseover
//          text: 'subtitle',
//          onclick() {
//            editor.execCommand('mceToggleFormat', false, 'h2')
//          },
//          onPostRender() {
//            const btn = this
//            editor.on('init', () => {
//              editor.formatter.formatChanged('h2', state => {
//                btn.active(state)
//              })
//            })
//          }
//        })
//        editor.addButton('p', {
//          title: 'text',
//          text: 'text',
//          onclick() {
//            editor.execCommand('mceToggleFormat', false, 'p')
//          },
//          onPostRender() {
//            const btn = this
//            editor.on('init', () => {
//              editor.formatter.formatChanged('p', state => {
//                btn.active(state)
//              })
//            })
//          }
//        })
      }
    })
  },
  methods: {
    imageSuccessCBK(arr) {
      //console.log("imageSuccessCBK received!", arr)
      const _this = this
      arr.forEach(v => {
        window.tinymce.get(_this.tinymceId).insertContent(`<img class="wscnph" src="${v.url}"  width="333" caption="false" >`)
      })
    },
    init_content(val) {
      //console.log("init_content received!", val)
      window.tinymce.get(this.tinymceId).setContent(val)
    }
  },
  destroyed() {
    window.tinymce.get(this.tinymceId).destroy()
  }
}
</script>

<style scoped>
.tinymce-container {
  position: relative
}
.tinymce-textarea {
  visibility: hidden;
  z-index: -1;
}
.editor-custom-btn-container {
  position: absolute;
  right: 5px;
  /*z-index: 10009999999999;*/
  bottom: 8px;
}
.editor-upload-btn {
  display: inline-block;
}
</style>
