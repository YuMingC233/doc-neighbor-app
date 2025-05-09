import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dn_app/api/login.dart';
import 'package:dn_app/routes/app_pages.dart';
// 百度地图相关包
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;

Future<void> main() async {
  // ignore: invalid_use_of_visible_for_testing_member
  runApp(MyApp());

  /// 动态申请定位权限
  requestPermission();

  LocationFlutterPlugin myLocPlugin = LocationFlutterPlugin();

  /// 设置用户是否同意SDK隐私协议
  /// since 3.1.0 开发者必须设置
  BMFMapSDK.setAgreePrivacy(true);
  myLocPlugin.setAgreePrivacy(true);

  // 百度地图sdk初始化鉴权
  if (Platform.isIOS) {
    myLocPlugin.authAK('kqveHUXZZvLaAmQMSrz0GtmUbCWW06Xa');
    BMFMapSDK.setApiKeyAndCoordType(
        'kqveHUXZZvLaAmQMSrz0GtmUbCWW06Xa', BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
    /// 初始化获取Android 系统版本号，如果低于10使用TextureMapView 等于大于10使用Mapview
    await BMFAndroidVersion.initAndroidVersion();
    // Android 目前不支持接口设置Apikey,
    // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
}

// 动态申请定位权限
void requestPermission() async {
  // 申请权限
  bool hasLocationPermission = await requestLocationPermission();
  if (hasLocationPermission) {
    // 权限申请通过
  } else {}
}

/// 申请定位权限
/// 授予定位权限返回true， 否则返回false
Future<bool> requestLocationPermission() async {
  //获取当前的权限
  var status = await Permission.location.status;
  if (status == PermissionStatus.granted) {
    //已经授权
    return true;
  } else {
    //未授权则发起一次申请
    status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
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
