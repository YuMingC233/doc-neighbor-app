import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/system/user.dart';

class PWDIndex extends StatefulWidget {
  const PWDIndex({Key? key}) : super(key: key);

  @override
  State<PWDIndex> createState() => _PWDIndexState();
}

class _PWDIndexState extends State<PWDIndex> {
  var oldPassword = "";
  var newPassword = "";
  var rawPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "修改密码",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent, // 背景颜色设置为透明
        shadowColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            height: 40,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        "旧密码",
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Container(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              oldPassword = value;
                            });
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "请输入旧密码",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 40,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        "新密码",
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Container(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              newPassword = value;
                            });
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "请输入新密码",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 40,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        "新密码",
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Container(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              rawPassword = value;
                            });
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "请输入新密码",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 35,
          ),
          Container(
              height: 45,
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                    shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))))),
                onPressed: () async {
                  if (oldPassword == "") {
                    Get.snackbar("系统提示", "原始密码不能为空");
                  }
                  print(rawPassword);
                  print(newPassword);
                  if (rawPassword == "" || rawPassword != newPassword) {
                    Get.snackbar("系统提示", "两次密码输入的不一致");
                    return;
                  }

                  var respData = await updateUserPwd({
                    "oldPassword": oldPassword,
                    "newPassword": newPassword,
                    "rawPassword": rawPassword
                  });
                  if (respData.data["code"] == 200) {
                    Get.back();
                    Get.snackbar("系统提示", respData.data["msg"]);
                  } else {
                    Get.snackbar("系统提示", respData.data["msg"]);
                  }
                },
                child: const Text(
                  "提交",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
