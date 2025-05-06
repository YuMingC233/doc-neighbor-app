import '../../utils/request.dart';

//获取用户信息
var getUserProfile = () async {
  return await DioRequest().httpRequest("/system/user/profile", true, "GET");
};

var getRouters = () async {
  return await DioRequest().httpRequest("/getRouters", true, "GET");
};

var updateProfile = (data) async {
  return await DioRequest()
      .httpRequest("/system/user/profile", true, "PUT", data: data);
};

var updateUserPwd = (data) async {
  return await DioRequest()
      .httpRequest("/system/user/profile/updatePwd", true, "PUT", data: data);
};
