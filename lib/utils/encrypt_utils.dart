import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:pointycastle/asymmetric/api.dart';

/// 加密工具类
class EncryptUtils {
  static const String encryptHeader = 'encrypt-key';
  static const bool enableEncrypt = true; // 是否启用加密，相当于环境变量控制

  /// 生成随机字符串
  static String generateRandomString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        32, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  /// 生成随机AES密钥
  static encrypt_lib.Key generateAesKey() {
    final randomString = generateRandomString();
    return encrypt_lib.Key.fromUtf8(randomString);
  }

  /// Base64编码
  static String encryptBase64(String data) {
    return base64.encode(utf8.encode(data));
  }

  /// Base64解码
  static String decryptBase64(String data) {
    return utf8.decode(base64.decode(data));
  }

  /// RSA加密 - 这里使用公钥加密AES密钥
  static String encrypt(String data) {
    // 这里应该使用你的RSA公钥，这只是一个示例
    // 在实际应用中，你应该从安全的地方获取公钥
    // TODO 基于环境变量获取公钥
    final publicKeyBase64 = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKoR8mX0rGKLqzcWmOzbfj64K8ZIgOdHnzkXSOVOZbFu/TJhZ7rFAN+eaGkl3C4buccQd/EjEsj9ir7ijT7h96MCAwEAAQ==';
    
    // 转换为PEM格式
    final publicKey = '-----BEGIN PUBLIC KEY-----\n$publicKeyBase64\n-----END PUBLIC KEY-----';
    
    final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.RSA(publicKey: encrypt_lib.RSAKeyParser().parse(publicKey) as RSAPublicKey));
    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;
  }

  /// RSA解密 - 这里使用私钥解密
  static String decrypt(String data) {
    // 这里应该使用你的RSA私钥，这只是一个示例
    // 在实际应用中，你应该从安全的地方获取私钥
    // TODO 基于环境变量获取私钥
    final privateKeyBase64 = 'MIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEAmc3CuPiGL/LcIIm7zryCEIbl1SPzBkr75E2VMtxegyZ1lYRD+7TZGAPkvIsBcaMs6Nsy0L78n2qh+lIZMpLH8wIDAQABAkEAk82Mhz0tlv6IVCyIcw/s3f0E+WLmtPFyR9/WtV3Y5aaejUkU60JpX4m5xNR2VaqOLTZAYjW8Wy0aXr3zYIhhQQIhAMfqR9oFdYw1J9SsNc+CrhugAvKTi0+BF6VoL6psWhvbAiEAxPPNTmrkmrXwdm/pQQu3UOQmc2vCZ5tiKpW10CgJi8kCIFGkL6utxw93Ncj4exE/gPLvKcT+1Emnoox+O9kRXss5AiAMtYLJDaLEzPrAWcZeeSgSIzbL+ecokmFKSDDcRske6QIgSMkHedwND1olF8vlKsJUGK3BcdtM8w4Xq7BpSBwsloE=';
    
    // 转换为PEM格式
    final privateKey = '-----BEGIN PRIVATE KEY-----\n$privateKeyBase64\n-----END PRIVATE KEY-----';
    
    final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.RSA(privateKey: encrypt_lib.RSAKeyParser().parse(privateKey) as RSAPrivateKey));
    final decrypted = encrypter.decrypt64(data);
    return decrypted;
  }

  /// AES加密数据 - 使用ECB模式，匹配JavaScript版本
  static String encryptWithAes(String data, encrypt_lib.Key aesKey) {
    // 使用ECB模式和PKCS7填充
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(
      aesKey,
      mode: encrypt_lib.AESMode.ecb, // 使用ECB模式
      padding: 'PKCS7', // 使用PKCS7填充
    ));
    
    // ECB模式不需要IV，但encrypt库API需要，所以传入空IV
    final encrypted = encrypter.encrypt(data, iv: encrypt_lib.IV.fromLength(0));
    return encrypted.base64;
  }

  /// AES解密数据 - 使用ECB模式，匹配JavaScript版本
  static String decryptWithAes(String encryptedData, encrypt_lib.Key aesKey) {
    // 使用ECB模式和PKCS7填充
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(
      aesKey,
      mode: encrypt_lib.AESMode.ecb, // 使用ECB模式
      padding: 'PKCS7', // 使用PKCS7填充
    ));
    
    // ECB模式不需要IV，但encrypt库API需要，所以传入空IV
    final decrypted = encrypter.decrypt64(encryptedData, iv: encrypt_lib.IV.fromLength(0));
    return decrypted;
  }

  /// 防重复提交的缓存
  static Map<String, dynamic>? _sessionObj;

  /// 检查重复提交
  static bool checkRepeatSubmit(String url, dynamic data, {int interval = 500}) {
    final requestObj = {
      'url': url,
      'data': data is Map ? jsonEncode(data) : data.toString(),
      'time': DateTime.now().millisecondsSinceEpoch
    };

    if (_sessionObj == null) {
      _sessionObj = requestObj;
      return false;
    } else {
      final s_url = _sessionObj!['url']; // 请求地址
      final s_data = _sessionObj!['data']; // 请求数据
      final s_time = _sessionObj!['time']; // 请求时间

      if (s_data == requestObj['data'] && 
          (requestObj['time'] as int) - (s_time as int) < interval && 
          s_url == requestObj['url']) {
        return true;
      } else {
        _sessionObj = requestObj;
        return false;
      }
    }
  }
}