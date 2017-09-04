<template>
  <el-form :model="ruleForm2" :rules="rules2" ref="ruleForm2" label-position="left" label-width="0px" class="demo-ruleForm login-container">
    <h3 class="title">Set new Password</h3>
    <el-form-item prop="old_pass">
      <el-input type="text" v-model="ruleForm2.old_pass" auto-complete="off" placeholder="old password"></el-input>
    </el-form-item>
    <el-form-item prop="new_pass">
      <el-input type="text" v-model="ruleForm2.new_pass" auto-complete="off" placeholder="new password"></el-input>
    </el-form-item>
    <el-form-item prop="new_pass2">
      <el-input type="password" v-model="ruleForm2.new_pass2" auto-complete="off" placeholder="repeat password"></el-input>
    </el-form-item>

    <el-form-item style="width:100%;">
      <el-button type="primary" style="width:100%;" @click.native.prevent="handleSubmit2" :loading="logining">Change password</el-button>

    </el-form-item>
    <el-form-item style="width:100%;">
      <el-button  style="width:100%;" @click.native.prevent="handleCancel2" :loading="logining">Cancel</el-button>

    </el-form-item>
  </el-form>

</template>

<script>
  import { requestResetPassword, cur_axios } from '../api/api';
  import axios from 'axios';
  //import NProgress from 'nprogress'
  export default {
    data() {
      return {
        logining: false,
        ruleForm2: {
          old_pass: '',
          new_pass: '',
          new_pass2: ''
        },
        rules2: {
          new_pass2: [
            { required: true, message: 'Please password twice', trigger: 'blur' },
//            { validator: this.validaePass }
          ],
          old_pass: [
            { required: true, message: 'Please enter your password', trigger: 'blur' },
//            { validator: validaePass }
          ]
        },
        checked: true
      };
    },
    methods: {
      validaePass() {

      },
      handleReset2() {
        this.$refs.ruleForm2.resetFields();
      },
      handleCancel2() {
        this.$router.push({path: window.history.back()});
      }
      ,
      handleSubmit2(ev) {
        this.$refs.ruleForm2.validate((valid) => {
          if (valid) {
            this.logining = true;
            var loginParams = { old_password: this.ruleForm2.old_pass, new_password: this.ruleForm2.new_pass };
            if (this.ruleForm2.new_pass != this.ruleForm2.new_pass2) {
              this.$message({
                message: "New passwords don't match!",
                type: 'error'
              });
              this.logining = false;
              return false
            }
            requestResetPassword(loginParams, this.$router.token).then(data => {
              let meta = data.meta;
              let result = data.result;
              this.logining = false;
              if (meta.code == 200) {
                if (result == "OK") {
                  this.$message({
                    message: "Password was changed!",
                    type: 'info'
                  });
                  this.$router.push({path: '/dashboard'});
                }else {
                  this.$message({
                    message: result,
                    type: 'info' //'error'
                  });

                }
              }else {
                this.$message({
                  message: 'something wrong!',
                  type: 'error'
                });



              }
            } )
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