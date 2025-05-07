import 'package:get_storage/get_storage.dart';

/// 用户角色管理类
/// 用于存储和管理用户角色类型，方便在应用中不同地方切换用户视图
class UserRoleManager {
  // 单例模式
  static final UserRoleManager _instance = UserRoleManager._internal();
  factory UserRoleManager() => _instance;
  UserRoleManager._internal();

  String _userRole = '0'; // 默认为普通用户：'0'，医生：'1'

  String get userRole => _userRole;

  /// 设置用户角色并保存到本地存储
  void setUserRole(String role) {
    _userRole = role;
    // 保存到存储中
    GetStorage().write("userRole", role);
  }

  /// 从本地存储初始化用户角色
  void initUserRole() {
    // 从存储中获取角色，如果没有则默认为'0'
    _userRole = GetStorage().read("userRole") ?? '0';
  }

  /// 根据登录返回的用户数据初始化用户角色
  static void init(Map<String, dynamic> userData) {
    // 从登录返回的数据中判断是否为医生
    bool isDoctor = userData["isDoctor"] ?? false;

    // 如果是医生，设置角色为'1'，否则为'0'
    String role = isDoctor ? '1' : '0';

    // 保存用户角色
    UserRoleManager()._userRole = role;
    GetStorage().write("userRole", role);
  }
}
