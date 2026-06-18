import 'shared_preferences_helper.dart';

class FcmTokenHelper {
  FcmTokenHelper._();

  static const String defaultTokenKey = 'fcm_token';

  static String? readStored({String tokenKey = defaultTokenKey}) {
    final raw = SharedPreferencesHelper.getData(key: tokenKey);
    if (raw == null) return null;
    final token = raw.toString().trim();
    return token.isEmpty ? null : token;
  }

  static void appendToBody(
    Map<String, dynamic> body, {
    String tokenKey = defaultTokenKey,
  }) {
    final token = readStored(tokenKey: tokenKey);
    if (token != null) {
      body['fcmToken'] = token;
    }
  }
}
