import 'dart:developer';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/session/user_session_keys.dart';

/// Registers the user FCM token with the backend immediately after fetch/refresh.
class FcmTokenRegistrar {
  FcmTokenRegistrar._();

  static Future<void> registerIfAuthenticated(String fcmToken) async {
    final token = fcmToken.trim();
    if (token.isEmpty) return;

    final authToken = (SharedPreferencesHelper.getData(key: UserSessionKeys.token) ?? '')
        .toString()
        .trim();
    if (authToken.isEmpty) {
      log('Skipping FCM token registration: user is not authenticated.');
      return;
    }

    try {
      await getIt<DioNetwork>().putData(
        endPoint: '/api/v1/user/notifications/token',
        data: <String, dynamic>{'fcmToken': token},
      );
      log('FCM token registered with backend.');
    } catch (error, stackTrace) {
      log(
        'Failed to register FCM token with backend: $error',
        stackTrace: stackTrace,
      );
    }
  }
}
