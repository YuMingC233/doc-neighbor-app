import "package:dio/dio.dart" as diopkg;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dn_app/utils/sputils.dart';
import 'package:dn_app/utils/encrypt_utils.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'dart:convert';

/// HTTP状态码
class HttpStatus {
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int ACCEPTED = 202;
  static const int CLIENT_ERROR = 400;
  static const int AUTHENTICATE = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404;
  static const int SERVER_ERROR = 500;
  static const int BAD_GATEWAY = 502;
  static const int SERVICE_UNAVAILABLE = 503;
  static const int GATEWAY_TIMEOUT = 504;
  static const int WARN = 601;
}

/// dio网络请求配置表 自定义
class DioConfig {
  //static const baseURL = "https://mouor.cn:8081"; 域名
  static const baseURL = "http://192.168.2.223:8080"; //域名
  static const timeout = 10000; //超时时间
}

// 网络请求工具类
class DioRequest {
  late diopkg.Dio dio;
  static DioRequest? _instance;
  // 重登录标记
  static bool _isRelogin = false;
  // 认证客户端id，静态字段
  static const String clientId = "0374f87a74fb14c09137345e48061d70";

  /// 构造函数
  DioRequest() {
    dio = diopkg.Dio();
    dio.options = diopkg.BaseOptions(
        baseUrl: DioConfig.baseURL,
        connectTimeout: DioConfig.timeout,
        sendTimeout: DioConfig.timeout,
        receiveTimeout: DioConfig.timeout,
        contentType: "application/json; charset=utf-8",
        headers: {});

    /// 请求拦截器
    dio.interceptors.add(diopkg.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 设置响应类型
        options.responseType = diopkg.ResponseType.json;

        // 是否需要token
        bool isToken = options.headers['isToken'] != false;
        // 是否需要防止数据重复提交
        bool isRepeatSubmit = options.headers['repeatSubmit'] != false;
        // 是否需要加密
        bool isEncrypt = options.headers['isEncrypt'] == 'true';

        // 添加token到请求头
        if (hasToken() && isToken) {
          options.headers['Authorization'] =
              'Bearer ${GetStorage().read("token")}';
        }

        // 处理POST和PUT请求参数，添加默认的clientId和grantType
        if (options.method == 'POST' || options.method == 'PUT') {
          if (options.data is Map) {
            final Map<String, dynamic> dataMap =
                Map<String, dynamic>.from(options.data);
            // 添加 clientId 参数，优先使用请求中的值，否则使用默认值
            dataMap['clientId'] = dataMap['clientId'] ?? clientId;
            // 添加 grantType 参数，优先使用请求中的值，否则使用默认值
            dataMap['grantType'] = dataMap['grantType'] ?? 'password';
            options.data = dataMap;
          }
        }

        // 处理GET请求参数
        if (options.method == 'GET' && options.queryParameters.isNotEmpty) {
          // 在Dio中，queryParameters会自动处理，不需要像Axios那样手动处理
        }

        // 防止重复提交
        if (isRepeatSubmit &&
            (options.method == 'POST' || options.method == 'PUT')) {
          if (EncryptUtils.checkRepeatSubmit(options.path, options.data)) {
            return handler.reject(
              diopkg.DioError(
                requestOptions: options,
                error: '数据正在处理，请勿重复提交',
              ),
            );
          }
        }

        // 加密请求数据
        if (EncryptUtils.enableEncrypt &&
            isEncrypt &&
            (options.method == 'POST' || options.method == 'PUT')) {
          // 生成AES密钥
          final aesKey = EncryptUtils.generateAesKey();
          // 使用RSA加密AES密钥
          // 将Key对象转为字符串
          final aesKeyString = aesKey.base64;
          options.headers[EncryptUtils.encryptHeader] =
              EncryptUtils.encrypt(aesKeyString);

          // 使用AES加密数据
          if (options.data != null) {
            final jsonData = options.data is Map || options.data is List
                ? jsonEncode(options.data)
                : options.data.toString();
            options.data = EncryptUtils.encryptWithAes(jsonData, aesKey);
          }
        }

        // 处理FormData
        // if (options.data is FormData) {
        //   options.headers.remove('Content-Type');
        // }

        print("================== 请求数据 ==========================");
        print("url = ${options.uri.toString()}");
        print("headers = ${options.headers}");
        print("params = ${options.data}");

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 尝试解密返回的数据
        if (EncryptUtils.enableEncrypt) {
          final keyStr = response.headers.value(EncryptUtils.encryptHeader);
          if (keyStr != null && keyStr.isNotEmpty) {
            final data = response.data;
            try {
              // 解密AES密钥
              final base64Str = EncryptUtils.decrypt(keyStr);
              final aesKeyString = EncryptUtils.decryptBase64(base64Str);
              // 将字符串转换为 Key 对象
              final aesKey = encrypt_lib.Key.fromBase64(aesKeyString);
              // 使用AES密钥解密数据
              final decryptData = EncryptUtils.decryptWithAes(data, aesKey);
              // 将JSON字符串转为JSON对象
              response.data = jsonDecode(decryptData);
            } catch (e) {
              print("数据解密失败: $e");
            }
          }
        }

        // 处理登录响应
        if (response.requestOptions.path == "/auth/login") {
          if (response.data["code"] == HttpStatus.SUCCESS) {
            var info = response.data["data"];
            // print("respone info: $info");

            GetStorage().write("token", info["access_token"]);
            SPUtil().setString("token", info["access_token"]);
          }
        }

        // 处理用户资料响应
        print("request path: ${response.requestOptions.path}");
        if (response.requestOptions.path == "/system/user/profile") {
          if (response.data["code"] == HttpStatus.SUCCESS) {
            var rawInfo = response.data["data"];
            var userInfo = rawInfo["user"];
            GetStorage().write("rawUserInfo", rawInfo);
            GetStorage().write("userName", userInfo["nickName"]);
            // 打印存储的信息
            // print("存储的Name: ${GetStorage().read("userName")}");
          }
        }

        // 处理路由数据响应
        if (response.requestOptions.path == "/getRouters") {
          if (response.data["code"] == HttpStatus.SUCCESS) {
            GetStorage().write("route", response.data["data"]);
          }
        }

        // 处理用户信息响应
        if (response.requestOptions.path == "/getInfo") {
          if (response.data["code"] == HttpStatus.SUCCESS) {
            GetStorage().write("nickName", response.data["user"]["nickName"]);
            GetStorage().write("userName", response.data["user"]["userName"]);
            SPUtil().setString(
                "avatar",
                response.data["user"]["avatar"] ??
                    "http://vue.ruoyi.vip/static/img/profile.473f5971.jpg");
          }
        }

        // 状态码处理
        final code = response.data["code"] ?? HttpStatus.SUCCESS;

        // 处理权限错误
        if (code == HttpStatus.FORBIDDEN) {
          SPUtil().clean();
          GetStorage().erase();
          Get.toNamed("/login");
          return handler.next(response);
        }

        // 处理认证错误
        if (code == HttpStatus.AUTHENTICATE) {
          if (!_isRelogin) {
            _isRelogin = true;
            // 使用局部变量跟踪是否已经处理了请求
            bool hasHandledRequest = false;

            Get.defaultDialog(
              barrierDismissible: false,
              title: "系统提示",
              middleText: "登录状态已过期，您可以继续留在该页面，或者重新登录",
              textConfirm: "重新登录",
              textCancel: "取消",
              confirmTextColor: Get.theme.primaryColor,
              onConfirm: () {
                _isRelogin = false;
                SPUtil().clean();
                GetStorage().erase();
                Get.offAllNamed("/login");
                // 标记请求已处理
                hasHandledRequest = true;
                handler.next(response);
              },
              onCancel: () {
                _isRelogin = false;
                // 标记请求已处理
                hasHandledRequest = true;
                handler.next(response);
              },
            );

            // 不立即返回reject，等待对话框操作完成
            return;
          }

          // 只有在没有显示对话框的情况下才会执行到这里
          return handler.reject(
            diopkg.DioError(
              requestOptions: response.requestOptions,
              error: '无效的会话，或者会话已过期，请重新登录',
            ),
          );
        } else if (code == HttpStatus.SERVER_ERROR) {
          final msg = response.data["msg"] ?? "服务器错误";
          Get.snackbar("错误", msg, snackPosition: SnackPosition.TOP);
          return handler.reject(
            diopkg.DioError(
              requestOptions: response.requestOptions,
              error: msg,
            ),
          );
        } else if (code == HttpStatus.WARN) {
          final msg = response.data["msg"] ?? "警告";
          Get.snackbar("警告", msg, snackPosition: SnackPosition.TOP);
          return handler.reject(
            diopkg.DioError(
              requestOptions: response.requestOptions,
              error: msg,
            ),
          );
        } else if (code != HttpStatus.SUCCESS) {
          final msg = response.data["msg"] ?? "未知错误";
          Get.snackbar("错误", msg, snackPosition: SnackPosition.TOP);
          return handler.reject(
            diopkg.DioError(
              requestOptions: response.requestOptions,
              error: "error",
            ),
          );
        }

        print("================== 响应数据 ==========================");
        print("code = ${response.statusCode}");
        print("data = ${response.data}");

        return handler.next(response);
      },
      onError: (diopkg.DioError e, handler) {
        String message = e.message;
        if (e.type == diopkg.DioErrorType.connectTimeout ||
            e.type == diopkg.DioErrorType.receiveTimeout ||
            e.type == diopkg.DioErrorType.sendTimeout) {
          message = '系统接口请求超时';
        } else if (e.type == diopkg.DioErrorType.response) {
          message = '系统接口${e.response?.statusCode}异常';
        } else if (e.type == diopkg.DioErrorType.other) {
          if (e.error == 'Network Error') {
            message = '后端接口连接异常';
          } else {
            message = '未知网络异常';
          }
        }

        Get.snackbar("网络错误", message, snackPosition: SnackPosition.TOP);

        print("================== 错误响应数据 ======================");
        print("type = ${e.type}");
        print("message = $message");

        return handler.next(e);
      },
    ));
  }

  static DioRequest getInstance() {
    return _instance ??= DioRequest();
  }

  /// 检查是否有token
  bool hasToken() {
    if (!GetStorage().hasData("token")) {
      var token = SPUtil().get("token");
      if (token != null) {
        GetStorage().write("token", token);
        return true;
      }
      return false;
    }
    return true;
  }

  /// HTTP请求
  httpRequest(
    String path,
    bool isToken,
    String method, {
    data,
    Map<String, dynamic>? queryParameters,
    diopkg.CancelToken? cancelToken,
    diopkg.Options? options,
    diopkg.ProgressCallback? onSendProgress,
    diopkg.ProgressCallback? onReceiveProgress,
    bool isEncrypt = false,
    bool isRepeatSubmit = true,
  }) async {
    diopkg.Options requestOptions;

    // 构建请求头
    Map<String, dynamic> headers = {
      "content-type": "application/json; charset=utf-8",
      "isToken": isToken,
      "repeatSubmit": isRepeatSubmit,
      "isEncrypt": isEncrypt ? "true" : "false",
    };

    // 添加token
    if (isToken && hasToken()) {
      headers["Authorization"] = "Bearer ${GetStorage().read("token")}";
    }
    // 添加客户端ID
    headers["clientId"] = clientId;

    // 创建options
    requestOptions = diopkg.Options(
      headers: headers,
      method: method,
    );

    // 合并可能的其他选项
    if (options != null) {
      requestOptions = requestOptions.copyWith(
        headers: options.headers,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        responseType: options.responseType,
        contentType: options.contentType,
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        requestEncoder: options.requestEncoder,
        responseDecoder: options.responseDecoder,
        listFormat: options.listFormat,
      );
    }

    // 执行请求
    try {
      diopkg.Response response;
      switch (method) {
        case "GET":
          response = await dio.get(
            path,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case "POST":
          response = await dio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case "PUT":
          response = await dio.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case "DELETE":
          response = await dio.delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
          );
          break;
        default:
          throw Exception("不支持的请求方法: $method");
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
