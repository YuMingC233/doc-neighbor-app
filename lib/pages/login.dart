import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:ruoyi_app/icon/ruoyi_icon.dart';

import '../api/login.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "登录",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent, // 背景颜色设置为透明
          shadowColor: Colors.transparent,
        ),
        body: const Login());
  }
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginIndex();
  }
}

// ignore: must_be_immutable
class LoginIndex extends StatefulWidget {
  const LoginIndex({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // ignore: no_logic_in_create_state
    return _LoginIndexState();
  }
}

class _LoginIndexState extends State<LoginIndex> {
  var url =
      "/9j/4AAQSkZJRgABAgAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAA8AKADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDtrW1ga1hZoIySikkoOeKsCztv+feL/vgU2z/484P+ua/yqyKiMY8q0IjGPKtCIWdr/wA+0P8A3wKeLK1/59of+/YqQVWuNVsbO5jt7m6ihlkUsiyNjcB1xmrjT5naKuPlj2JxZWn/AD6w/wDfsU4WNp/z6wf9+xWXqHizQ9LV";

  var uuid = "";
  var password = "admin123";
  var username = "admin";
  var code = "";
  var tenantId = "";
  var tenantEnabled = false;
  var tenantList = [];

  @override
  // ignore: must_call_super
  void initState() {
    // TODO: implement initState
    getImg();
    getTenants();
  }

  // ignore: prefer_typing_uninitialized_variables

  void getImg() async {
    try {
      var resp = await getImage();

      Map<String, dynamic> responseData = resp["data"];
      print("responseData.toString()=$responseData");

      setState(() {
        url = responseData["img"].toString();
        uuid = responseData["uuid"].toString();
      });
    } catch (e) {
      print(e);
    }
  }

  void getTenants() async {
    try {
      var resp = await getTenantList();

      if (resp["code"] == 200 && resp["data"] != null) {
        var data = resp["data"] as Map<String, dynamic>;
        // 检查是否启用租户功能
        var tenantEnabledFromServer = data["tenantEnabled"] ?? false;

        setState(() {
          tenantEnabled = tenantEnabledFromServer;
          // 只有在启用租户的情况下才处理租户列表
          if (tenantEnabled && data["voList"] != null) {
            tenantList = data["voList"] as List;
            // 如果有租户列表，默认选择第一个
            if (tenantList.isNotEmpty) {
              tenantId = tenantList[0]["tenantId"].toString();
            }
          } else {
            tenantList = [];
          }
        });
      }
    } catch (e) {
      print("获取租户列表出错: $e");
      setState(() {
        tenantEnabled = false;
        tenantList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域时收起键盘
        FocusScope.of(context).unfocus();
      },
      child: Center(
          child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 40, right: 40),
              children: [
                const SizedBox(
                  height: 60,
                ),
                const Center(
                  child: LogInIcon(),
                ),
                const SizedBox(
                  height: 70,
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25.0)),
                      border: Border.all(width: 1.0)),
                  child: TextField(
                    onChanged: (value) {
                      username = value;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(RuoYiIcons.user),
                      border: InputBorder.none,
                      hintText: "请输入用户名 ",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                // 添加租户选择下拉框
                if (tenantEnabled) ...[
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        border: Border.all(width: 1.0)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tenantId,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        hint: const Text("请选择用户组"),
                        onChanged: (String? newValue) {
                          setState(() {
                            tenantId = newValue!;
                          });
                        },
                        items: tenantList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item["tenantId"].toString(),
                            child: Row(
                              children: [
                                const Icon(Icons.business, size: 20),
                                const SizedBox(width: 10),
                                Text(item["companyName"].toString()),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25.0)),
                      border: Border.all(width: 1.0)),
                  child: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(RuoYiIcons.password),
                      border: InputBorder.none,
                      hintText: "请输入密码 ",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              onChanged: (value) {
                                code = value;
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                icon: Icon(RuoYiIcons.code),
                                border: InputBorder.none,
                                hintText: "请输入验证码 ",
                              ),
                            )),
                        Expanded(
                            flex: 5,
                            child: InkWell(
                                onTap: () {
                                  getImg();
                                },
                                child: Image.memory(
                                  const Base64Decoder().convert(url),
                                  fit: BoxFit.fill,
                                ))),
                      ],
                    )),
                const SizedBox(
                  height: 45,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed("/register");
                    },
                    child: const Text(
                      "没有账号？点击注册",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
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
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(25.0))))),
                      onPressed: () async {
                        if (username.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  const AlertDialog(
                                    content: Text(
                                      '用户名不能为空！！',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ));
                          return;
                        }
                        if (password.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  const AlertDialog(
                                    content: Text(
                                      '密码不能为空！！',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ));
                          return;
                        }
                        if (code.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  const AlertDialog(
                                    content: Text(
                                      '验证码不能为空！！',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ));
                          return;
                        }
                        var requestData = {
                          "uuid": uuid,
                          "username": username,
                          "password": password,
                          "code": code
                        };

                        // 如果启用了租户功能并且选择了租户，则添加租户ID到请求数据中
                        if (tenantEnabled && tenantId.isNotEmpty) {
                          requestData["tenantId"] = tenantId;
                        }

                        var data = await logInByClient(requestData);

                        if (data["code"] == 200) {
                          // ignore: use_build_context_synchronously
                          Get.toNamed("/home");
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    content: Text(
                                      data["msg"],
                                      style:
                                          const TextStyle(color: Colors.cyan),
                                    ),
                                  ));
                          getImg();
                        }
                      },
                      child: const Text(
                        "登录",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                        text: "登录即代表同意",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "《用户协议》",
                            style: const TextStyle(color: Colors.red),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed("/login/webView", arguments: {
                                  "title": "用户服务协议",
                                  "url": "https://ruoyi.vip/protocol.html"
                                });
                              },
                          ),
                          TextSpan(
                            text: "《用户隐私》",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed("/login/webView", arguments: {
                                  "title": "隐私政策",
                                  "url": "https://ruoyi.vip/protocol.html"
                                });
                              },
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class LogInIcon extends StatelessWidget {
  const LogInIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        "static/logo.png",
      ),
      title: const Text(
        "若依移动端登录",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
