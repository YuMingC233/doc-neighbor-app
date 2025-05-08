import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dn_app/pages/nearby_doctor/index.dart';
import 'package:dn_app/utils/user_role_manager.dart';
import 'package:dn_app/widgets/navigation_map.dart'; // 导入导航地图组件

class HomeIndex extends StatefulWidget {
  const HomeIndex({Key? key}) : super(key: key);

  @override
  State<HomeIndex> createState() => _HomeIndexState();
}

class _HomeIndexState extends State<HomeIndex> {
  // 模拟状态变量
  bool emergencyActive = false;
  bool acceptedEmergency = false;

  @override
  void initState() {
    super.initState();
    // 确保角色管理器已初始化
    UserRoleManager().initUserRole();

    // 模拟一段时间后收到紧急请求
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          emergencyActive = true;
        });
      }
    });
  }

  void acceptRequest() {
    setState(() {
      acceptedEmergency = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 根据用户角色显示不同的UI
    String userRole = UserRoleManager().userRole;
    return userRole == '0' ? _buildPatientView() : _buildDoctorView();
  }

  // 普通用户（患者）视图
  Widget _buildPatientView() {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "医邻救援",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "紧急情况下，点击下方按钮寻求附近医生的帮助",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      // 使用Get路由，避免Navigator堆栈问题
                      Get.to(() => const NearbyDoctorPage());
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "紧急救助",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 医生视图
  Widget _buildDoctorView() {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // 顶部蓝色标题栏
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[600],
              width: double.infinity,
              child: const SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "医生端",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "您目前处于在线状态，可接收紧急救助请求",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 主体内容区域
            Expanded(
              child: emergencyActive && !acceptedEmergency
                  ? _buildEmergencyRequest()
                  : acceptedEmergency
                      ? _buildAcceptedRequest()
                      : _buildWaitingState(),
            ),
          ],
        ),
      ),
    );
  }

  // 紧急救助请求卡片
  Widget _buildEmergencyRequest() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "紧急救助请求！",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "患者位置: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "武汉市洪山区珞瑜路"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "距离您: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "0.5公里 (约2分钟)"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "病情描述: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "突发胸痛，疑似心脏问题"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: acceptRequest,
                      icon: const Icon(Icons.check),
                      label: const Text("接受请求"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 已接受的请求状态
  Widget _buildAcceptedRequest() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "您已接受此紧急救助！",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "请尽快前往患者位置",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const NavigationMap(
              patientLatitude: 30.5168, // 这里使用模拟的患者位置坐标，实际中应该从服务端获取
              patientLongitude: 114.3433, // 武汉市大致坐标
              patientAddress: "武汉市洪山区珞瑜路",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // 联系患者功能
            },
            icon: const Icon(Icons.phone),
            label: const Text("联系患者"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[500],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 等待状态
  Widget _buildWaitingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 60,
              color: Colors.blue[500],
            ),
            const SizedBox(height: 16),
            Text(
              "等待紧急救助请求",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "您将收到附近5公里范围内的紧急医疗救助请求",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
