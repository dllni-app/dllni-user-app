import 'package:common_package/common_package.dart';

class LoginParams with Params {
  static const String fcmTokenPrefsKey = FcmTokenHelper.defaultTokenKey;

  final String phone;
  final String password;

  LoginParams({required this.phone, required this.password});

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'phone': phone,
      'password': password,
      'module': 'user',
    };
    FcmTokenHelper.appendToBody(body, tokenKey: fcmTokenPrefsKey);
    return body;
  }
}
