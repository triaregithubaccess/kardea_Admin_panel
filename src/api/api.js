import axios from 'axios';

let base = 'http://gena.mac:5505';

export const requestLogin = params => { return axios.post(`${base}/users/login_with_email`, params).then(res => res.data); };

export const getUserList = params => { return axios.get(`${base}/user/list`, { params: params }); };

export const getUserListPage = params => { return axios.get(`${base}/users`, { params: params }); };

export const getChannelListPage = params => {return axios.get(`${base}/channels`, { params: params }); };
export const editChannel = (params, token) => {return axios.post(`${base}/channels/${params._id}`, params); };

export const getArticleListPage2 = params => {return axios.get(`${base}/articles`, { params: params }); };
export const editArticle2 = (params, token) => {return axios.post(`${base}/articles/${params._id}`, params); };

export const getArticleListPage = params => {return axios.get(`${base}/channels/${params.che_id}/articles`, { params: params }); };
export const editArticle = (params, token) => {return axios.post(`${base}/articles/${params._id}`, params); };

export const removeUser = params => {return axios.delete(`${base}/users/${params._id}`, { params: params }); };

export const batchRemoveUser = params => { return axios.get(`${base}/user/batchremove`, { params: params }); };

export const editUser = params => { return axios.get(`${base}/user/edit`, { params: params }); };

export const addUser = params => { return axios.get(`${base}/user/add`, { params: params }); };

export const api_domen =  `${base}`
export const image_upload_url2 =  `${base}/user/upload?width=103&height=103`

export const cur_axios = axios;