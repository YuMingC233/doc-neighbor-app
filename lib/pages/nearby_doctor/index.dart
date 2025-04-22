import 'package:flutter/material.dart';
import 'dart:async';

class NearbyDoctorPage extends StatefulWidget {
  const NearbyDoctorPage({Key? key}) : super(key: key);

  @override
  State<NearbyDoctorPage> createState() => _NearbyDoctorPageState();
}

class _NearbyDoctorPageState extends State<NearbyDoctorPage> {
  // 定义需要的状态变量
  List<Doctor> doctors = [];
  Doctor? acceptedDoctor;
  int countdown = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 模拟数据加载
    Timer(Duration(seconds: 1), () {
      setState(() {
        doctors = mockDoctors;
        isLoading = false;
      });
    });

    // 倒计时效果
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // 模拟医生数据
  List<Doctor> get mockDoctors => [
    Doctor(id: 1, name: '张医生', specialty: '急诊医学', distance: '0.3公里', rating: 4.9),
    Doctor(id: 2, name: '李医生', specialty: '内科', distance: '0.5公里', rating: 4.7),
    Doctor(id: 3, name: '王医生', specialty: '急救医学', distance: '0.8公里', rating: 4.8),
  ];

  // 取消紧急情况
  void cancelEmergency() {
    Navigator.of(context).pop();
  }

  // 接受医生请求
  void acceptRequest(Doctor doctor) {
    setState(() {
      acceptedDoctor = doctor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // 确保内容不被状态栏遮挡
        child: Column(
          children: [
            // 紧急求助提示条
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFEE2E2), // bg-red-100
              child: Column(
                children: [
                  Text(
                    "紧急求助已发送",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFDC2626), // text-red-600
                    ),
                  ),
                  Text(
                    "正在寻找附近医生...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563), // text-gray-600
                    ),
                  ),
                ],
              ),
              width: double.infinity,
              alignment: Alignment.center,
            ),
            
            // 主要内容区域
            Expanded(
              child: acceptedDoctor != null 
                  ? _buildAcceptedDoctorView()
                  : _buildNearbyDoctorsView(),
            ),
            
            // 底部取消按钮
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 26), // 增加底部边距到26dp
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cancelEmergency,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("取消求助"),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD1D5DB), // bg-gray-300
                    foregroundColor: Color(0xFF374151), // text-gray-700
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 医生已接单视图
  Widget _buildAcceptedDoctorView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 医生已接单提示
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFDCFCE7), // bg-green-100
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "医生已接单！",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A), // text-green-600
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.black87),
                    SizedBox(width: 8),
                    Text("${acceptedDoctor!.name} (${acceptedDoctor!.specialty})"),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "预计到达时间: 约${acceptedDoctor!.distance}，${(double.parse(acceptedDoctor!.distance.replaceAll('公里', '')) * 3).round()}分钟",
                ),
              ],
            ),
          ),
          
          // 位置共享区域
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6), // bg-gray-100
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(bottom: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 40, color: Color(0xFF9CA3AF)), // text-gray-400
                  SizedBox(width: 8),
                  Text(
                    "实时位置共享",
                    style: TextStyle(
                      color: Color(0xFF6B7280), // text-gray-500
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 联系医生按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 18),
                    SizedBox(width: 8),
                    Text("联系医生"),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6), // bg-blue-500
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 附近医生列表视图
  Widget _buildNearbyDoctorsView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "附近医生 (${doctors.length})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: isLoading || doctors.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        countdown > 0
                            ? "搜索附近医生中... ($countdown)"
                            : "正在搜索附近医生...",
                        style: TextStyle(
                          color: Color(0xFF6B7280), // text-gray-500
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return GestureDetector(
                        onTap: () => acceptRequest(doctor),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFE5E7EB), // border-gray-200
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    doctor.distance,
                                    style: TextStyle(
                                      color: Color(0xFF6B7280), // text-gray-500
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                doctor.specialty,
                                style: TextStyle(
                                  color: Color(0xFF4B5563), // text-gray-600
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "评分: ${doctor.rating}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 医生数据类
class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String distance;
  final double rating;
  bool accepted;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.distance,
    required this.rating,
    this.accepted = false,
  });
}