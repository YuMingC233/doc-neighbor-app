import '../utils/request.dart';

var getInfo = () async {
  return await DioRequest().httpRequest("/system/user/profile", true, "GET");
};

var getImage = () async {
  return await DioRequest().httpRequest("/auth/code", false, "GET");
};

var getTenantList = () async {
  return await DioRequest().httpRequest("/auth/tenant/list", false, "GET");
};

var logInByClient = (data) async {
  return await DioRequest().httpRequest("/auth/login", false, "POST", data: data, isEncrypt: true);
};

var register = (data) async {
  return await DioRequest().httpRequest("/auth/register", false, "POST", data: data, isEncrypt: true);
};
