import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/di/injection.dart';
import 'core/session/session_expired_handler.dart';
import 'core/utils/app_date_time_locale.dart';

Future<void> main() async {
  Intl.defaultLocale = AppDateTimeLocale.languageCode;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(AppDateTimeLocale.intlLocale);
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final navigatorKey = GlobalKey<NavigatorState>();
  SessionExpiredHandler.navigatorKey = navigatorKey;

  await configureInjection();

  await bootstrapApp(
    AppBootstrapConfig(
      navigatorKey: navigatorKey,
      app: App(navigatorKey: navigatorKey),
      configureDependencies: () async {},
      enableNotifications: true,
      startLocale: Locale('ar'),
      fallbackLocale: const Locale('ar'),
      supportedLocales: const <Locale>[AppDateTimeLocale.locale, Locale('ar')],
      translationsAssetPath: 'assets/translations',
      fcmTokenKey: 'fcm_token',
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(getIt<DeepLinkService>().init(navigatorKey: navigatorKey));
  });
}
