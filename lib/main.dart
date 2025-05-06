import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dn_app/api/login.dart';
import 'package:dn_app/routes/app_pages.dart';

void main() {
  // ignore: invalid_use_of_visible_for_testing_member

  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // 根据是否存在用户token返回路由地址
  String defaultTokenPage =
      GetStorage().hasData("token") ? AppPages.INITIAL : AppPages.INITIALLOGIN;

  @override
  Widget build(BuildContext context) {
    // 设置初始路由地址
    GetStorage().write(
        "initialRoute",
        // 如果有 token 则跳转到首页，否则跳转到登录页
        // default_token_page
        "/home");
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,

      ///国际化 自定义配置 目前配置了 英语和中文
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale("en", "US"), Locale("zh", "CN")],

      // 应用的初始路由是从 GetStorage 中读取的
      initialRoute: GetStorage().read("initialRoute"),
      getPages: AppPages.routes,
      routingCallback: (routing) {
        if (routing?.current != "/login" &&
            routing?.current != "/login/webView" &&
            routing?.current != "/register") {
          getInfo();
        }
      },
    );
  }
}
