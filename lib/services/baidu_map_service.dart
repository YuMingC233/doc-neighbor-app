import 'dart:async';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_baidu_mapapi_utils/flutter_baidu_mapapi_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class BaiduMapService {
  static final BaiduMapService _instance = BaiduMapService._internal();

  // 单例模式
  factory BaiduMapService() => _instance;

  BaiduMapService._internal();

  // 地图控制器
  BMFMapController? mapController;

  // 当前位置
  BMFLocation? currentLocation;

  // 患者位置
  BMFLocation? patientLocation;

  // 定位信息更新流
  final StreamController<BMFLocation> _locationStreamController =
      StreamController<BMFLocation>.broadcast();
  Stream<BMFLocation> get locationStream => _locationStreamController.stream;

  // 定位功能
  loc.Location location = loc.Location();
  bool _isServiceRunning = false;

  // 初始化百度地图SDK
  Future<bool> initBaiduMap() async {
    // 申请权限
    await requestPermission();

    // 设置是否同意隐私政策
    BMFMapSDK.setAgreePrivacy(true);

    // 正确的百度地图初始化方法
    // 使用setCoordType设置坐标类型
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);

    // 如果有API Key，也可以使用下面的方法同时设置API Key和坐标类型
    // String apiKey = "您的百度地图API KEY";
    // BMFMapSDK.setApiKeyAndCoordType(apiKey, BMF_COORD_TYPE.BD09LL);

    // 初始化搜索功能 - 使用正确的搜索初始化方式
    // 创建检索实例以完成初始化
    BMFWalkingRouteSearch walkingRouteSearch = BMFWalkingRouteSearch();

    // 这里假定初始化成功
    return true;
  }

  // 申请定位权限
  Future<bool> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();

    return statuses[Permission.location]!.isGranted ||
        statuses[Permission.locationWhenInUse]!.isGranted ||
        statuses[Permission.locationAlways]!.isGranted;
  }

  // 开始实时定位
  Future<void> startLocationService() async {
    if (_isServiceRunning) {
      return;
    }

    _isServiceRunning = true;

    // 检查位置服务是否启用
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // 检查权限
    loc.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return;
      }
    }

    // 设置定位参数
    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 3000, // 定位频率，3秒
    );

    // 订阅位置变化
    location.onLocationChanged.listen((loc.LocationData locationData) {
      // 更新当前位置
      final BMFCoordinate coordinate = BMFCoordinate(
        locationData.latitude ?? 0.0,
        locationData.longitude ?? 0.0,
      );

      currentLocation = BMFLocation(
        coordinate: coordinate,
        altitude: locationData.altitude ?? 0.0,
        horizontalAccuracy: locationData.accuracy ?? 0.0,
        course: locationData.heading ?? 0.0,
        speed: locationData.speed ?? 0.0,
      );

      // 发送位置更新
      _locationStreamController.add(currentLocation!);

      // 更新地图中心点位置
      if (mapController != null) {
        // 创建 BMFUserLocation 对象来替代直接使用 BMFLocation
        BMFUserLocation userLocation = BMFUserLocation(
          location: currentLocation,
          heading: BMFHeading(
            magneticHeading: locationData.heading ?? 0.0,
            trueHeading: locationData.heading ?? 0.0,
          ),
        );
        mapController!.updateLocationData(userLocation);
      }
    });

    // 启动定位
    await location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: "医邻救援",
      subtitle: "位置共享中",
      description: "提供位置共享服务，为患者提供及时救援",
    );
  }

  // 停止定位服务
  void stopLocationService() {
    if (!_isServiceRunning) {
      return;
    }

    location.enableBackgroundMode(enable: false);
    _isServiceRunning = false;
  }

  // 设置患者位置（模拟）
  void setPatientLocation(double latitude, double longitude) {
    patientLocation = BMFLocation(
      coordinate: BMFCoordinate(latitude, longitude),
    );

    // 如果地图控制器已初始化，在地图上添加患者位置标记
    if (mapController != null &&
        patientLocation != null &&
        patientLocation!.coordinate != null) {
      // 创建患者位置标记
      BMFMarker patientMarker = BMFMarker(
        position: patientLocation!.coordinate!,
        title: "患者位置",
        identifier: "patient_marker",
        icon: "static/images/patient_marker.png",
      );

      // 添加标记到地图
      mapController!.addMarker(patientMarker);
    }
  }

  // 计算导航路线
  Future<BMFWalkingRouteResult?> calculateWalkingRoute() async {
    if (currentLocation == null || patientLocation == null) {
      return null;
    }

    // 创建检索参数
    BMFWalkingRoutePlanOption walkingRoutePlanOption =
        BMFWalkingRoutePlanOption(
      from: BMFPlanNode(pt: currentLocation!.coordinate),
      to: BMFPlanNode(pt: patientLocation!.coordinate),
    );

    // 创建检索实例
    BMFWalkingRouteSearch walkingRouteSearch = BMFWalkingRouteSearch();

    // 检索
    bool result =
        await walkingRouteSearch.walkingRouteSearch(walkingRoutePlanOption);

    if (result) {
      // 等待结果
      Completer<BMFWalkingRouteResult> completer =
          Completer<BMFWalkingRouteResult>();

      walkingRouteSearch.onGetWalkingRouteSearchResult(callback:
          (BMFWalkingRouteResult result, BMFSearchErrorCode errorCode) {
        if (errorCode == BMFSearchErrorCode.NO_ERROR) {
          completer.complete(result);
        } else {
          completer.completeError("路线规划失败: $errorCode");
        }
      });

      try {
        return await completer.future;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // 在地图上绘制路线
  void drawRouteOnMap(BMFWalkingRouteResult routeResult) {
    if (mapController == null ||
        routeResult.routes == null ||
        routeResult.routes!.isEmpty) {
      return;
    }

    // 获取第一条步行路线
    BMFWalkingStep? walkingStep = routeResult.routes![0].steps![0];

    if (walkingStep.points != null) {
      // 创建折线参数
      BMFPolyline polyline =
          BMFPolyline(coordinates: walkingStep.points!, width: 5);

      // 添加折线到地图
      mapController!.addPolyline(polyline);
    }
  }

  // 获取两点之间距离（米）
  Future<double> getDistance() async {
    if (currentLocation == null ||
        patientLocation == null ||
        currentLocation!.coordinate == null ||
        patientLocation!.coordinate == null) {
      return 0.0;
    }

    double? distance = await BMFCalculateUtils.getLocationDistance(
        currentLocation!.coordinate!, patientLocation!.coordinate!);

    return distance ?? 0.0;
  }

  // 获取大致的行程时间（分钟）
  Future<int> getEstimatedTime() async {
    // 假设平均步行速度为5公里/小时，即约1.4米/秒
    double distance = await getDistance();
    return (distance / (1.4 * 60)).round(); // 转换为分钟
  }

  // 销毁
  void dispose() {
    stopLocationService();
    mapController = null;
    _locationStreamController.close();
  }
}
