import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/session/session_expired_handler.dart';

Future<void> main() async {
  final navigatorKey = GlobalKey<NavigatorState>();
  SessionExpiredHandler.navigatorKey = navigatorKey;

  await bootstrapApp(
    AppBootstrapConfig(
      navigatorKey: navigatorKey,
      app: App(navigatorKey: navigatorKey),
      configureDependencies: configureInjection,
      enableNotifications: true,
      startLocale: Locale('ar'),
      fallbackLocale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
      translationsAssetPath: 'assets/translations',
      fcmTokenKey: 'fcm_token',
    ),
  );
}
