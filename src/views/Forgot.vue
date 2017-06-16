<template  lang="pug">
  el-form( :model="ruleForm2", :rules="rules", ref="ruleForm2", label-position="left", label-width="0px", class="demo-ruleForm, login-container")
    h3( class="title") Forgot password
    el-form-item( prop="account")
      el-input( type="text", v-model="ruleForm2.email", auto-complete="off", placeholder="email")
    el-form-item( style="width:100%;")
      el-button( type="primary", style="width:100%;", @click.native.prevent="handleSubmit", :loading="sending") Send me email with password
    a( href="#/login") Login
</template>

<script>
  import { requestForgot, cur_axios } from '../api/api';
  import axios from 'axios';

  export default {
    data() {
      return {
        sending: false,
        ruleForm2: {
          email: ''
        },
        rules: {
          email: [
            { required: true, message: 'Please input email', trigger: 'blur' },
            //{ validator: validaePass }
          ]
        },
        checked: true
      };
    },
    methods: {

      handleSubmit(ev) {
        var _this = this;

        this.$refs.ruleForm2.validate((valid) => {
          if (valid) {
            this.sending = true;

            var forgotParams = { email: this.ruleForm2.email};

            requestForgot(forgotParams).then(data => {
              this.sending = false;

              let { meta, result} = data.data;
              if (meta.code !== 200) {
                this.$message({
                  message: "User with this Email not found! ",
                  type: 'error'
                });
              } else {
                this.$router.push({ path: '/' });
              }
            });
          } else {
            console.log('error submit!!');
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