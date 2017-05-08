// Generated by CoffeeScript 1.12.5
var params, router;

import babelpolyfill from 'babel-polyfill';

import Vue from 'vue';

import App from './App.vue';

import ElementUI from 'element-ui';

import locale from 'element-ui/lib/locale/lang/en';

import './assets/theme/theme-custom/index.css';

import VueRouter from 'vue-router';

import store from './vuex/store.js';

import Vuex from 'vuex';

import routes from './routes.js';

import Mock from './mock/mock.js';

import 'font-awesome/css/font-awesome.min.css';

Vue.use(ElementUI, {
  locale: locale
});

Vue.use(VueRouter);

Vue.use(Vuex);

router = new VueRouter({
  routes: routes
});

router.beforeEach((function(_this) {
  return function(to, from, next) {
    var user;
    console.log("router each---------------------------");
    if (to.path === '/login') {
      sessionStorage.removeItem('user');
    }
    user = JSON.parse(sessionStorage.getItem('user'));
    console.log("user=", user != null);
    if ((user != null ? user.token : void 0) != null) {
      console.log("tok=", user.token);
      router.token = user.token;
      console.log("tok2=", router.token);
    }
    if (!user && to.path !== '/login') {
      return next({
        path: '/login'
      });
    } else {
      return next();
    }
  };
})(this));

params = {
  router: router,
  store: store,
  render: (function(_this) {
    return function(h) {
      return h(App);
    };
  })(this)
};

new Vue(params).$mount('#app');

//# sourceMappingURL=main.js.map
