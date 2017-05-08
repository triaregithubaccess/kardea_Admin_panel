import axios from 'axios';

let base = 'http://localhost:5505';

export const requestLogin = params => { return axios.post(`${base}/users/login_with_email`, params).then(res => res.data); };

export const getUserList = params => { return axios.get(`${base}/user/list`, { params: params }); };

export const getUserListPage = params => { return axios.get(`${base}/users`, { params: params }); };

export const getChannelListPage = params => {return axios.get(`${base}/channels`, { params: params }); };
export const editChannel = (params, token) => {
    console.log("in Edit Che!", token);
    return axios.post(`${base}/channels/${params._id}`, params); };

export const removeUser = params => {
    console.log("del params=",params);
    return axios.delete(`${base}/users/${params._id}`, { params: params }); };

export const batchRemoveUser = params => { return axios.get(`${base}/user/batchremove`, { params: params }); };

export const editUser = params => { return axios.get(`${base}/user/edit`, { params: params }); };

export const addUser = params => { return axios.get(`${base}/user/add`, { params: params }); };

export const cur_axios = axios;