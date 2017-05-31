import axios from 'axios';

let base = 'http://localhost:5505';
//let base = 'http://138.201.108.157:5505';

export const requestLogin = params => {
    console.log("base=", base);
    return axios.post(`${base}/users/login_with_email`, params).then(res => res.data); };

export const getUserList = params => { return axios.get(`${base}/user/list`, { params: params }); };

export const getUserListPage = params => { return axios.get(`${base}/users`, { params: params }); };

export const getChannelListPage = params => {return axios.get(`${base}/channels`, { params: params }); };
export const getChannelShortListPage = params => {return axios.get(`${base}/channels?select=_id,title`, { params: params }); };
export const editChannel = (params, token) => {return axios.post(`${base}/channels/${params._id}?token=${token}`, params); };

export const getArticleListPage = params => {return axios.get(`${base}/articles`, { params: params }); };
export const getArticleListPageByChe = params => {return axios.get(`${base}/channels/${params.che_id}/articles`, { params: params }); };
export const editArticle = (params, token) => {return axios.post(`${base}/articles/${params._id}?token=${token}`, params); };
export const removeArticle = (params, token) => {return axios.delete(`${base}/articles/${params._id}?token=${token}`, params); };
export const addArticle = (params, token) => {return axios.put(`${base}/articles?token=${token}`, params); };

export const getTagListPage = params => {return axios.get(`${base}/tags?select=_id,name`, { params: params }); };
export const editTag = (params, token) => {return axios.post(`${base}/tags/${params._id}?token=${token}`, params); };
export const addTag = (params, token) => {return axios.put(`${base}/tags?token=${token}`, params); };
export const removeTag = (params, token) => {return axios.delete(`${base}/tags/${params._id}?token=${token}`, params); };

export const getCommentListPage = params => {return axios.get(`${base}/comments`, { params: params }); };
export const getArticlesCommentListPage = params => {return axios.get(`${base}/articles/${params['article_id']}/comments`, { params: params }); };
export const editComment = (params, token) => {console.log('in api: ', token); return axios.post(`${base}/comments/${params._id}?token=${token}`, params); };
export const addComment = (params, token) => {return axios.put(`${base}/comments?token=${token}`, params); };
export const removeComment = (params, token) => {return axios.delete(`${base}/comments/${params._id}?token=${token}`, params); };

export const getAllTags = (params, token) => {return axios.get(`${base}/tags?select=name&as_array=true&sort=name&token=${token}`, { params: params }); };

export const getBWListPage = params => {return axios.get(`${base}/badwords`, { params: params }); };
export const editBW = (params, token) => {return axios.post(`${base}/badwords/${params._id}?token=${token}`, params); };
export const addBW = (params, token) => {return axios.put(`${base}/badwords?token=${token}`, params); };
export const removeBW = (params, token) => {return axios.delete(`${base}/badwords/${params._id}?token=${token}`, params); };

export const removeUser = (params, token) => { return axios.delete(`${base}/users/${params._id}?token=${token}`, { params: params }); };

export const batchRemoveUser = params => { return axios.get(`${base}/user/batchremove`, { params: params }); };

export const editUser = params => { return axios.get(`${base}/user/edit`, { params: params }); };

export const addUser = params => { return axios.get(`${base}/user/add`, { params: params }); };

export const api_domen =  `${base}`
export const image_upload_url2 =  `${base}/user/upload?width=103&height=103`

export const cur_axios = axios;