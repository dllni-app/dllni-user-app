import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/realtime/cleaning_booking_pusher_service.dart';
import 'package:flutter/material.dart';

class SessionExpiredHandler {
  SessionExpiredHandler._();

  static GlobalKey<NavigatorState>? navigatorKey;
  static bool _isNavigatingToLogin = false;

  static Future<void> handle() async {
    if (_isNavigatingToLogin) return;
    final token = (SharedPreferencesHelper.getData(key: 'token') ?? '')
        .toString()
        .trim();
    if (token.isEmpty) return;

    _isNavigatingToLogin = true;
    try {
      await getIt<CleaningBookingPusherService>().disposeAllForSession();
      await SharedPreferencesHelper.clearData();
      navigatorKey?.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } finally {
      _isNavigatingToLogin = false;
    }
  }
}
