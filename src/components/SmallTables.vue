<template lang="pug">
	section

		//el-row

		el-col(:span="14")
			onetable( :myp='tagApiService' )

		el-col(:span="9")
			onetable( :myp='badwordApiService')

		el-col.toolbar(:span='24')


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
		f1: 'name',
    f1_caps: 'Name',
    need_lang: true,
    name_t_ph:'tag name',
    name_t: 'TAGs'
	};

  let badwordApiService = {
		getList: getBWListPage,
		addItem: addBW ,
    editItem: editBW,
    removeItem: removeBW,
		f1: 'word',
    f1_caps: 'Word',
    need_lang: false,
    name_t_ph: 'bad word',
    name_t: 'Bad Words'
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
			}
		},
		methods: { }
	}

</script>

<style scoped>

</style>