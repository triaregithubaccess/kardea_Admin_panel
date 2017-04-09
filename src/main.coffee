import babelpolyfill from 'babel-polyfill'
import Vue from 'vue'
import App from './App.vue'
import ElementUI from 'element-ui'
import locale from 'element-ui/lib/locale/lang/en'
#import 'element-ui/lib/theme-default/index.css'
import './assets/theme/theme-custom/index.css'
#import './styles/theme/button.css'
import VueRouter from 'vue-router'
import store from './vuex/store.js'
import Vuex from 'vuex'
#//import NProgress from 'nprogress'
#//import 'nprogress/nprogress.css'
import routes from './routes.js'
import Mock from './mock/mock.js'
Mock.bootstrap()
import 'font-awesome/css/font-awesome.min.css'

Vue.use ElementUI, { locale }
Vue.use VueRouter
Vue.use Vuex

#//NProgress.configure({ showSpinner: false });

router = new VueRouter { routes }

router.beforeEach (to, from, next) =>
#  //NProgress.start();
  sessionStorage.removeItem 'user' if to.path is '/login'
  user = JSON.parse sessionStorage.getItem('user')
  if !user and to.path != '/login'
    next path: '/login'
  else
    next()

#//router.afterEach(transition => {
#//NProgress.done();
#//});

#params =
#  #  //el: '#app',
#  #  //template: '<App/>',
#  router: router
#  store: store
#  #  //components: { App }
#  render: h => h(App)

params =
  router: router
  store: store
  render: (h) => h(App)

new Vue(params).$mount('#app')
