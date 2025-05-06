import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dn_app/icon/ruoyi_icon.dart';

import '../api/login.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "注册",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // 表单数据
  var username = "";
  var password = "";
  var confirmPassword = "";
  var code = "";

  // 验证码相关
  var url = "";
  var uuid = "";
  var captchaEnabled = true;

  @override
  void initState() {
    super.initState();
    getCode();
  }

  // 获取验证码
  void getCode() async {
    try {
      var resp = await getImage();

      Map<String, dynamic> responseData = resp["data"];

      setState(() {
        url = responseData["img"].toString();
        uuid = responseData["uuid"].toString();
        captchaEnabled = responseData["captchaEnabled"] ?? true;
      });
    } catch (e) {
      print(e);
    }
  }

  // 处理注册请求
  void handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // 验证密码是否匹配
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次输入的密码不一致')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        var requestData = {
          "username": username,
          "password": password,
          "userType": "app_user",
          "code": code,
          "uuid": uuid
        };

        var response = await register(requestData);

        if (response["code"] == 200) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('系统提示'),
              content: Text('注册成功！用户名：$username'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.offNamed('/login'); // 注册成功后跳转到登录页
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response["msg"] ?? '注册失败，请稍后再试')),
          );
          if (captchaEnabled) {
            getCode(); // 刷新验证码
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册请求失败: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域收起键盘
        FocusScope.of(context).unfocus();
      },
      child: Center(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        "DocNeighbor用户注册",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 用户名输入
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          border: Border.all(width: 1.0)),
                      child: TextFormField(
                        onChanged: (value) {
                          username = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          if (value.length < 2 || value.length > 20) {
                            return '用户名长度必须在2-20个字符之间';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(RuoYiIcons.user),
                          border: InputBorder.none,
                          hintText: "请输入用户名",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 密码输入
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          border: Border.all(width: 1.0)),
                      child: TextFormField(
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (value.length < 5 || value.length > 20) {
                            return '密码长度必须在5-20个字符之间';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(RuoYiIcons.password),
                          border: InputBorder.none,
                          hintText: "请输入密码",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 确认密码
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          border: Border.all(width: 1.0)),
                      child: TextFormField(
                        obscureText: true,
                        onChanged: (value) {
                          confirmPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认密码';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(RuoYiIcons.password),
                          border: InputBorder.none,
                          hintText: "请确认密码",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 验证码（如果启用）
                    if (captchaEnabled)
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(25.0)),
                            border: Border.all(width: 1.0)),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  onChanged: (value) {
                                    code = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入验证码';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    icon: Icon(RuoYiIcons.code),
                                    border: InputBorder.none,
                                    hintText: "请输入验证码",
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: url.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : InkWell(
                                      onTap: getCode,
                                      child: Image.memory(
                                        const Base64Decoder().convert(url),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),

                    // 注册按钮
                    Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.blue),
                          shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                        onPressed: isLoading ? null : handleRegister,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "注册",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 返回登录页链接
                    Center(
                      child: TextButton(
                        onPressed: () => Get.offNamed('/login'),
                        child: const Text(
                          "已有账号？返回登录",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
