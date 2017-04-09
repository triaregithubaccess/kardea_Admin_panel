import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { LoginUsers, Users } from './data/user';
_Users = Users;

export_default =
#  /**
#   * mock bootstrap
#   */
  bootstrap: ->
    mock = new MockAdapter(axios)

#    // mock success request
    mock.onGet('/success').reply 200,
      msg: 'success'

#    // mock error request
    mock.onGet('/error').reply 500,
      msg: 'failure'

#    // Login
    mock.onPost('/login').reply (config) =>
      {username, password} = JSON.parse(config.data);
      new Promise (resolve, reject) =>
        user = null;
        setTimeout =>
          hasUser = LoginUsers.some (u) =>
            if u.username is username && u.password is password
              user = JSON.parse(JSON.stringify(u));
              user.password = undefined;
              return true;

          if hasUser
            resolve([200, { code: 200, msg: '请求成功', user }]);
          else
            resolve([200, { code: 500, msg: '账号或密码错误' }]);
        , 1000

#    //获取用户列表
    mock.onGet('/user/list').reply (config) =>
      {name} = config.params;
      mockUsers = _Users.filter (user) =>
        if name && user.name.indexOf(name) == -1
          return false;
        return true;
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve([200,  users: mockUsers ]);
        , 1000

#    //获取用户列表（分页）
    mock.onGet('/user/listpage').reply (config) =>
      {page, name} = config.params;
      mockUsers = _Users.filter (user) =>
        if name && user.name.indexOf(name) == -1
          return false;
        return true;
      total = mockUsers.length;
      mockUsers = mockUsers.filter((u, index) => index < 20 * page && index >= 20 * (page - 1));
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve [200,
            total: total,
            users: mockUsers
          ]
        , 1000

    mock.onGet('/user/remove').reply (config) =>
      { id } = config.params;
      _Users = _Users.filter (u) => u.id isnt id
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve [200,
            code: 200,
            msg: '删除成功'
          ]
        , 500

#    //批量删除用户
    mock.onGet('/user/batchremove').reply (config) =>
      { ids } = config.params;
      ids = ids.split(',');
      _Users = _Users.filter((u) => !ids.includes(u.id));
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve [200,
            code: 200,
            msg: '删除成功'
          ]
        , 500

#    //编辑用户
    mock.onGet('/user/edit').reply (config) =>
      { id, name, addr, age, birth, sex } = config.params;
      _Users.some u =>
        if u.id is id
          u.name = name;
          u.addr = addr;
          u.age = age;
          u.birth = birth;
          u.sex = sex;
          return true;
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve [200,
            code: 200,
            msg: '编辑成功'
          ]
        , 500

#    //新增用户
    mock.onGet('/user/add').reply (config) =>
      { name, addr, age, birth, sex } = config.params;
      _Users.push
        name: name,
        addr: addr,
        age: age,
        birth: birth,
        sex: sex
      return new Promise (resolve, reject) =>
        setTimeout  =>
          resolve [200,
            code: 200,
            msg: '新增成功'
          ]
        , 500

`export default export_default;`