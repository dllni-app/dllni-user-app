import 'package:common_package/common_package.dart';

class LoginParams with Params {
  static const String fcmTokenPrefsKey = 'fcm_token';

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
    final fcmToken = _readStoredFcmToken();
    if (fcmToken != null) {
      body['fcmToken'] = fcmToken;
    }
    return body;
  }

  static String? _readStoredFcmToken() {
    final raw = SharedPreferencesHelper.getData(key: fcmTokenPrefsKey);
    if (raw == null) return null;
    final token = raw.toString().trim();
    return token.isEmpty ? null : token;
  }
}
