import Login from './views/Login.vue'
import Forgot from './views/Forgot.vue'
import Reset from './views/Reset.vue'
import NotFound from './views/404.vue'
import Home from './views/Home.vue'
import Main from './views/Main.vue'
import UsersList from './views/nav1/UsersList.vue'
import ChannelsList from './views/nav1/Channels.vue'
import ArticlesList from './components/Articles.vue'
import PreArticlesList from './components/Articles.vue'
import CommentsList from './components/Comments.vue'
import DefinitionsList from './components/Definitions.vue'
import Dashboard from './components/Dashboard.vue'
import Analytics from './components/Analytics.vue'
import SmallTables from './components/SmallTables.vue'
import Form from './views/nav1/Form.vue'
import user from './views/nav1/user.vue'
import Page4 from './views/nav2/Page4.vue'
import Page5 from './views/nav2/Page5.vue'
import Page6 from './views/nav3/Page6.vue'
import echarts from  './views/charts/echarts.vue'

routes = [
  # when will add more routes - check line 27 in Home.vue ("$router.options.routes[4].children[0].path" )
    {
        path: '/login'
        component: Login
        name: ''
        hidden: true
    }
    {
      path: '/forgot'
      component: Forgot
      name: ''
      hidden: true
    }
    {
        path: '/reset'
        component: Reset
        name: ''
        hidden: true
    }
    {
        path: '/404'
        component: NotFound
        name: ''
        hidden: true
    }
    {
        path: '/'
        component: Home
        hidden: true
        name: 'Dashboard'
        iconCls: 'el-icon-message'
        children: [
          { path: '/dashboard', component: Dashboard, name: 'Dashboard'}
          ]
    }
    {
        path: '/'
        component: Home
        hidden: true
        name: 'Analytics'
        iconCls: 'el-icon-message'
        children: [
          { path: '/analytics', component: Analytics, name: 'Analytics'}
          ]
    }
    {
        path: '/'
        component: Home
        name: 'Tables'
        iconCls: 'el-icon-menu'
        children: [
            { path: '/main', component: Main, name: 'Main-1', hidden: true }
            { path: '/users', component: UsersList, name: 'Users' }
            { path: '/channels', component: ChannelsList, name: 'Topics' }
            { path: '/articles', component: ArticlesList, name: 'Articles' , props: { pre: false }}
            { path: '/prearticles', component: PreArticlesList, name: 'Pre Articles', props: { pre: true } }
            { path: '/comments', component: CommentsList, name: 'Comments' }
            { path: '/comments/:id', component: CommentsList, name: 'Comments', hidden:true }
            { path: '/definitions', component: DefinitionsList, name: 'Definitions' }
            { path: '/smalls', component: SmallTables, name: 'Small Tables' }
#            { path: '/form', component: Form, name: 'Form' }
#            { path: '/user', component: user, name: 'User' }
        ]
    }
#    {
#        path: '/'
#        component: Home
#        name: 'Charts'
#        iconCls: 'fa fa-bar-chart'
#        children: [
#            { path: '/echarts', component: echarts, name: 'echarts' }
#        ]
#    }
    {
        path: '*'
        hidden: true
        redirect: { path: '/404' }
    }
]

`export default routes;`