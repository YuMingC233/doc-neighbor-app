import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:dn_app/services/baidu_map_service.dart';

class NavigationMap extends StatefulWidget {
  // 患者位置坐标
  final double patientLatitude;
  final double patientLongitude;
  final String patientAddress;

  const NavigationMap({
    Key? key,
    required this.patientLatitude,
    required this.patientLongitude,
    required this.patientAddress,
  }) : super(key: key);

  @override
  State<NavigationMap> createState() => _NavigationMapState();
}

class _NavigationMapState extends State<NavigationMap> {
  // 百度地图服务
  final BaiduMapService _mapService = BaiduMapService();

  // 地图创建完成标志
  bool _isMapReady = false;

  // 路线规划结果
  BMFWalkingRouteResult? _routeResult;

  // 刷新定时器
  Timer? _refreshTimer;

  // 距离和时间
  double _distance = 0.0;
  int _estimatedTime = 0;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  // 初始化地图
  Future<void> _initMap() async {
    // 初始化百度地图
    await _mapService.initBaiduMap();

    // 设置患者位置
    _mapService.setPatientLocation(
        widget.patientLatitude, widget.patientLongitude);

    // 开始位置服务
    await _mapService.startLocationService();

    // 监听位置更新
    _mapService.locationStream.listen((_) {
      _updateRouteInfo();
    });

    // 每30秒重新计算一次路线
    // _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    //   _calculateRoute();
    // });
  }

  // 更新路线信息
  Future<void> _updateRouteInfo() async {
    if (mounted && _mapService.currentLocation != null) {
      final distance = await _mapService.getDistance();
      final estimatedTime = await _mapService.getEstimatedTime();
      if (mounted) {
        setState(() {
          _distance = distance;
          _estimatedTime = estimatedTime;
        });
      }
    }
  }

  // 计算路线
  // Future<void> _calculateRoute() async {
  //   final routeResult = await _mapService.calculateWalkingRoute();
  //   if (routeResult != null && mounted) {
  //     setState(() {
  //       _routeResult = routeResult;
  //     });

  //     // 绘制路线
  //     _mapService.drawRouteOnMap(routeResult);
  //   }
  // }

  // 创建地图视图
  Future<BMFMapController?> _onBMFMapCreated(
      BMFMapController controller) async {
    _mapService.mapController = controller;

    // 设置地图类型为标准地图
    await controller.updateMapOptions(BMFMapOptions(
      mapType: BMFMapType.Standard,
    ));

    // 开启用户位置显示
    await controller.showUserLocation(true);

    // 设置用户位置显示模式
    BMFUserTrackingMode trackingMode = BMFUserTrackingMode.Follow;
    await controller.setUserTrackingMode(trackingMode);

    // 设置患者位置
    if (_mapService.patientLocation != null && false) {
      // 创建患者位置标记
      BMFMarker patientMarker = BMFMarker.icon(
        position: _mapService.patientLocation!.coordinate!,
        title: "患者位置",
        subtitle: widget.patientAddress,
        identifier: "patient_marker",
        icon: "static/images/tabbar/mine_.png", // 确保此图片存在于项目资源中
      );

      // 添加标记到地图
      await controller.addMarker(patientMarker);
    }

    // 计算并绘制路线
    // _calculateRoute();

    setState(() {
      _isMapReady = true;
    });

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地图视图
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BMFMapWidget(
                onBMFMapCreated: _onBMFMapCreated,
                mapOptions: BMFMapOptions(
                  mapType: BMFMapType.Standard,
                  center: BMFCoordinate(
                      widget.patientLatitude, widget.patientLongitude),
                  zoomLevel: 16,
                  mapPadding:
                      BMFEdgeInsets(top: 0, left: 0, right: 0, bottom: 0),
                ),
              ),
            ),
          ),
        ),

        // 导航信息
        if (_isMapReady && false)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.straighten,
                            color: Colors.blue[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "距离: ${(_distance / 1000).toStringAsFixed(2)}公里",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.blue[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "预计: $_estimatedTime分钟",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "患者位置: ${widget.patientAddress}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapService.dispose();
    super.dispose();
  }
}
