<template>
  <el-form :model="ruleForm2" :rules="rules2" ref="ruleForm2" label-position="left" label-width="0px" class="demo-ruleForm login-container">
    <h3 class="title">Login</h3>
    <el-form-item prop="account">
      <el-input type="text" v-model="ruleForm2.account" auto-complete="off" placeholder="email"></el-input>
    </el-form-item>
    <el-form-item prop="checkPass">
      <el-input type="password" v-model="ruleForm2.checkPass" auto-complete="off" placeholder="password"></el-input>
    </el-form-item>
    <el-checkbox v-model="checked" checked class="remember">remember me</el-checkbox>
    <el-form-item style="width:100%;">
      <el-button type="primary" style="width:100%;" @click.native.prevent="handleSubmit2" :loading="logining">log in</el-button>

    </el-form-item>
    <a href="#/forgot">Forgot password</a>
  </el-form>

</template>

<script>
  import { requestLogin, cur_axios } from '../api/api';
  import axios from 'axios';
  //import NProgress from 'nprogress'
  export default {
    data() {
      return {
        logining: false,
        ruleForm2: {
          account: '', //'eee@eee.com',
          checkPass: '' // pass
        },
        rules2: {
          account: [
            { required: true, message: 'Please input Username', trigger: 'blur' },
            //{ validator: validaePass }
          ],
          checkPass: [
            { required: true, message: 'Please enter your password', trigger: 'blur' },
            //{ validator: validaePass2 }
          ]
        },
        checked: true
      };
    },
    methods: {
      handleReset2() {
        this.$refs.ruleForm2.resetFields();
      },
      handleSubmit2(ev) {
        var _this = this;
        this.$refs.ruleForm2.validate((valid) => {
          if (valid) {
            //_this.$router.replace('/table');
            this.logining = true;
            //NProgress.start();
            //console.log("pered login ")
            var loginParams = { login: true, email: this.ruleForm2.account, password: this.ruleForm2.checkPass };
            requestLogin(loginParams).then(data => {
              this.logining = false;
//              console.log("data in login =", data);
              let { meta,  result , token} = data;
              if (meta.code !== 200) {
                this.$message({
                  message: meta.message,
                  type: 'error'
                });
              } else {
                let user = result
                user.token = token
                sessionStorage.setItem('user', JSON.stringify(user));
                this.$router.token = token
                let toto = JSON.parse( sessionStorage.getItem('toto'))
                if (toto != undefined && toto != '/') {
                  console.log("TO toto", toto)
                  this.$router.push({ path: toto     });
                } else {
                  console.log("TO Dash")
                  this.$router.push({ path: '/dashboard' });
                }
              }
            });
          } else {
            return false;
          }
        });
      }
    }
  }

</script>

<style lang="scss" scoped>
  a {
    color: blue;

    text-decoration: underline;
  }
  .login-container {
    /*box-shadow: 0 0px 8px 0 rgba(0, 0, 0, 0.06), 0 1px 0px 0 rgba(0, 0, 0, 0.02);*/
    -webkit-border-radius: 5px;
    border-radius: 5px;
    -moz-border-radius: 5px;
    background-clip: padding-box;
    margin: 180px auto;
    width: 350px;
    padding: 35px 35px 15px 35px;
    background: #fff;
    border: 1px solid #eaeaea;
    box-shadow: 0 0 25px #cac6c6;
    .title {
      margin: 0px auto 40px auto;
      text-align: center;
      color: #505458;
    }
    .remember {
      margin: 0px 0px 35px 0px;
    }
  }
</style>