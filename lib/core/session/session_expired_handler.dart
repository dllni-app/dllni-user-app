import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

/// Global session expiry: clear storage and navigate to login once per burst.
class SessionExpiredHandler {
  SessionExpiredHandler._();

  static GlobalKey<NavigatorState>? navigatorKey;

  static bool _handling = false;

  static Future<void> handle() async {
    if (_handling) return;
    _handling = true;
    try {
      await SharedPreferencesHelper.clearData();
      navigatorKey?.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    } finally {
      _handling = false;
    }
  }
}
