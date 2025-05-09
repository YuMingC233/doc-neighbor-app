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
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;

// 全局变量，用于在应用中访问定位插件
final LocationFlutterPlugin locPlugin = LocationFlutterPlugin();

Future<void> main() async {
  // ignore: invalid_use_of_visible_for_testing_member
  runApp(MyApp());

  /// 动态申请定位权限
  requestPermission();

  /// 设置用户是否同意SDK隐私协议
  /// since 3.1.0 开发者必须设置
  BMFMapSDK.setAgreePrivacy(true);
  locPlugin.setAgreePrivacy(true);

  // 百度地图sdk初始化鉴权
  if (Platform.isIOS) {
    locPlugin.authAK('kqveHUXZZvLaAmQMSrz0GtmUbCWW06Xa');
    BMFMapSDK.setApiKeyAndCoordType(
        'kqveHUXZZvLaAmQMSrz0GtmUbCWW06Xa', BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
    /// 初始化获取Android 系统版本号，如果低于10使用TextureMapView 等于大于10使用Mapview
    await BMFAndroidVersion.initAndroidVersion();
    // Android 目前不支持接口设置Apikey,
    // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }

  setLocParams();
}

///
/// 设置定位参数
///
void setLocParams() async {
  // IOS地图定位初始参数
  BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
      // 坐标系
      coordType: BMFLocationCoordType.bd09ll,
      // 位置获取超时时间
      locationTimeout: 10,
      // 获取地址信息超时时间
      reGeocodeTimeout: 10,
      // 应用位置类型 默认为automotiveNavigation
      activityType: BMFActivityType.automotiveNavigation,
      // 设置预期精度参数 默认为best
      desiredAccuracy: BMFDesiredAccuracy.best,
      // 是否需要最新版本rgc数据
      isNeedNewVersionRgc: true,
      // 指定定位是否会被系统自动暂停
      pausesLocationUpdatesAutomatically: false,
      // 指定是否允许后台定位,
      // 允许的话是可以进行后台定位的，但需要项目配置允许后台定位，否则会报错，具体参考开发文档
      allowsBackgroundLocationUpdates: true,
      // 设定定位的最小更新距离
      distanceFilter: 10,
    );
    return options;
  }

  Map iosMap = initIOSOptions().getMap();

  // 安卓地图定位初始参数
  BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
        // 定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        locationMode: BMFLocationMode.hightAccuracy,
        // 是否需要返回地址信息
        isNeedAddress: true,
        // 是否需要返回海拔高度信息
        isNeedAltitude: false,
        // 是否需要返回周边poi信息
        isNeedLocationPoiList: false,
        // 是否需要返回新版本rgc信息
        isNeedNewVersionRgc: true,
        // 是否需要返回位置描述信息
        isNeedLocationDescribe: true,
        // 是否使用gps
        openGps: true,
        // 可选，设置场景定位参数，包括签到场景、运动场景、出行场景
        locationPurpose: BMFLocationPurpose.sport,
        // 坐标系
        coordType: BMFLocationCoordType.bd09ll,
        // 设置发起定位请求的间隔，int类型，单位ms
        // 如果设置为0，则代表单次定位，即仅定位一次，默认为0
        scanspan: 0);
    return options;
  }

  Map androidMap = initAndroidOptions().getMap();

  await locPlugin.prepareLoc(androidMap, iosMap);
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
