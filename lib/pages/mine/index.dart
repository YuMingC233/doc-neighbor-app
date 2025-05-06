import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruoyi_app/icon/ruoyi_icon.dart';

import '../../api/system/user.dart';

// 全局变量，用于存储用户角色类型，默认为普通用户
class UserRoleManager {
  static final UserRoleManager _instance = UserRoleManager._internal();
  factory UserRoleManager() => _instance;
  UserRoleManager._internal();

  String _userRole = '0'; // 默认为普通用户：'0'，医生：'1'

  String get userRole => _userRole;

  void setUserRole(String role) {
    _userRole = role;
    // 保存到存储中
    GetStorage().write("userRole", role);
  }

  void initUserRole() {
    // 从存储中获取角色，如果没有则默认为'0'
    _userRole = GetStorage().read("userRole") ?? '0';
  }
}

class MineIndex extends StatefulWidget {
  const MineIndex({Key? key}) : super(key: key);

  @override
  State<MineIndex> createState() => _MineIndexState();
}

class _MineIndexState extends State<MineIndex> {
  @override
  void initState() {
    super.initState();
    // 初始化用户角色
    UserRoleManager().initUserRole();
  }

  // 显示角色切换对话框
  void _showRoleSwitchDialog() {
    String currentRole = UserRoleManager().userRole;
    String targetRole = currentRole == '0' ? '1' : '0';
    String targetRoleName = targetRole == '0' ? '普通用户' : '医生';

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('切换角色'),
              content: Text('是否要切换为$targetRoleName？'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    // 先关闭对话框
                    Navigator.of(context).pop();

                    // 切换角色
                    UserRoleManager().setUserRole(targetRole);

                    // 更新UI
                    setState(() {});

                    // 使用Get导航到首页并清除所有之前的路由
                    // 使用Future.delayed确保pop操作完成后再执行导航
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Get.offAllNamed('/home');
                    });
                  },
                  child: const Text('确认'),
                ),
              ],
            ));
  }

  // 显示功能正在开发中的提示
  void _showUnderDevelopmentDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('注意'),
              content: const Text('该功能正在开发中，敬请期待！'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前角色名称用于显示
    String roleDisplayName = UserRoleManager().userRole == '0' ? '普通用户' : '医生';
    double BlueHeight = 240;
    return MaterialApp(
      home: Scaffold(
          // 移除默认的AppBar
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: Container(),
          ),
          // 防止系统状态栏遮挡内容
          extendBodyBehindAppBar: true,
          body: SafeArea(
            // 将top设为false，让内容延伸到状态栏
            top: false,
            child: Container(
              child: ListView(
                // 移除ListView的内边距
                padding: EdgeInsets.zero,
                // 禁用ListView的滚动行为
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: const FractionalOffset(0.5, 0),
                        child: Container(
                          height: BlueHeight,
                          color: Colors.blue[600],
                          padding: const EdgeInsets.only(top: 80),
                          child: ListTile(
                            onTap: () async {
                              // TODO 跳转信息详情页
                              var data = await getUserProfile().then((value) {
                                if (value["code"] == 200) {
                                  Get.toNamed("/home/info",
                                      arguments: {"args": value["data"]});
                                }
                              }, onError: (e) {
                                print(e);
                              });
                              // _showUnderDevelopmentDialog();
                            },
                            leading: ClipOval(
                              child: Image.asset(
                                "static/images/profile.jpg",
                                width: 58,
                                height: 58,
                              ),
                            ),
                            title: Text(
                              //${SPUtil().get("name")}
                              "${GetStorage().read("userName") ?? "未登录"}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20),
                            ),
                            subtitle: Text(
                              // SPUtil().get("name"),
                              GetStorage().read("rawUserInfo")["user"]
                                      ["deptName"] ??
                                  roleDisplayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const FractionalOffset(0.5, 0),
                        child: Container(
                          height: 110,
                          margin:
                              EdgeInsets.fromLTRB(15, BlueHeight - 60, 15, 0),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: GridView.count(
                            physics:
                                const NeverScrollableScrollPhysics(), // Disable scrolling
                            crossAxisCount: 4,
                            crossAxisSpacing: 10.0,
                            padding: const EdgeInsets.all(25.0),
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showUnderDevelopmentDialog();
                                },
                                child: const SingleChildScrollView(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Disable scrolling
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Icon(
                                          Icons.supervisor_account_rounded,
                                          size: 35,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      Text("用户交流"),
                                    ],
                                  ),
                                ),
                              ),
                              const SingleChildScrollView(
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable scrolling
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        RuoYiIcons.service,
                                        size: 35,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text("在线客服"),
                                  ],
                                ),
                              ),
                              const SingleChildScrollView(
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable scrolling
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        RuoYiIcons.community,
                                        size: 35,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text("反馈社区"),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _showRoleSwitchDialog,
                                child: const SingleChildScrollView(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Disable scrolling
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Icon(
                                          RuoYiIcons.user,
                                          size: 35,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text("切换角色"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: const FractionalOffset(0.78, 0),
                        child: Container(
                          height: 280,
                          margin:
                              EdgeInsets.fromLTRB(15, BlueHeight + 65, 15, 0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: SingleChildScrollView(
                            physics:
                                const NeverScrollableScrollPhysics(), // Disable scrolling
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    ///TODO 跳转编辑资料页
                                    // getProfile().then((value) => Get.toNamed(
                                    //     "/home/userEdit",
                                    //     arguments: {"arg": value.data}));
                                    _showUnderDevelopmentDialog();
                                  },
                                  leading: const Icon(
                                    Icons.perm_identity,
                                    color: Colors.blue,
                                  ),
                                  title: const Text(
                                    "编辑资料",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () async {
                                    ///TODO 跳转常见问题页
                                    await Get.toNamed("/home/help");
                                  },
                                  leading: const Icon(
                                    Icons.help_outline,
                                    color: Colors.blue,
                                  ),
                                  title: const Text(
                                    "常见问题",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () async {
                                    ///TODO 跳转关于我们页
                                    await Get.toNamed("/home/about");
                                  },
                                  leading: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.blue,
                                  ),
                                  title: const Text(
                                    "关于我们",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () async {
                                    ///TODO 跳转应用设置页
                                    await Get.toNamed("/home/settings");
                                  },
                                  leading: const Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                  ),
                                  title: const Text(
                                    "应用设置",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
