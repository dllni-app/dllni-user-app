import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class SessionExpiredHandler {
  SessionExpiredHandler._();

  static GlobalKey<NavigatorState>? navigatorKey;
  static bool _isNavigatingToLogin = false;

  static Future<void> handle() async {
    if (_isNavigatingToLogin) return;

    _isNavigatingToLogin = true;
    try {
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
