import Login from './views/Login.vue'
import NotFound from './views/404.vue'
import Home from './views/Home.vue'
import Main from './views/Main.vue'
import Table from './views/nav1/Table.vue'
import Form from './views/nav1/Form.vue'
import user from './views/nav1/user.vue'
import Page4 from './views/nav2/Page4.vue'
import Page5 from './views/nav2/Page5.vue'
import Page6 from './views/nav3/Page6.vue'
import echarts from './views/charts/echarts.vue'

routes = [
    {
        path: '/login'
        component: Login
        name: ''
        hidden: true
    }
    {
        path: '/404'
        component: NotFound
        name: ''
        hidden: true
    }
#    //{ path: '/main', component: Main },
    {
        path: '/'
        component: Home
        name: 'Main'
        iconCls: 'el-icon-message'
        children: [
            { path: '/main', component: Main, name: 'Main-1', hidden: true }
            { path: '/table', component: Table, name: 'Table' }
            { path: '/form', component: Form, name: 'Form' }
            { path: '/user', component: user, name: 'User' }
        ]
    }
    {
        path: '/'
        component: Home
        name: 'Navigation'
        iconCls: 'fa fa-id-card-o'
        children: [
            { path: '/page4', component: Page4, name: 'page4' }
            { path: '/page5', component: Page5, name: 'page5' }
        ]
    }
    {
        path: '/'
        component: Home
        name: ''
        iconCls: 'fa fa-address-card'
        leaf: true
        children: [
            { path: '/page6', component: Page6, name: 'Page6' }
        ]
    }
    {
        path: '/'
        component: Home
        name: 'Charts'
        iconCls: 'fa fa-bar-chart'
        children: [
            { path: '/echarts', component: echarts, name: 'echarts' }
        ]
    }
    {
        path: '*'
        hidden: true
        redirect: { path: '/404' }
    }
]

`export default routes;`