import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'app.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/di/injection.dart';
import 'core/notifications/fcm_token_registrar.dart';
import 'core/session/session_expired_handler.dart';
import 'core/session/user_session_sync_service.dart';
import 'core/utils/app_date_time_locale.dart';
import 'core/utils/debug_file_logger.dart';
import 'core/utils/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebugFileLogger.init();

  await DebugFileLogger.runGuarded(() async {
    Intl.defaultLocale = AppDateTimeLocale.languageCode;
    await initializeDateFormatting(AppDateTimeLocale.intlLocale);
    await initializeDateFormatting('ar');
    if (kIsWeb) {
      usePathUrlStrategy();
    }

    final navigatorKey = GlobalKey<NavigatorState>();
    SessionExpiredHandler.navigatorKey = navigatorKey;

    await configureInjection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        NotificationHelper.initAllNotifications(
          tokenKey: 'fcm_token',
          navigatorKey: navigatorKey,
          onFcmTokenAvailable: FcmTokenRegistrar.registerIfAuthenticated,
        ),
      );
      unawaited(UserSessionSyncService.syncOnStartup());
      unawaited(getIt<DeepLinkService>().init(navigatorKey: navigatorKey));
      unawaited(UpdateService.checkOnStartup(navigatorKey: navigatorKey));
    });

    await bootstrapApp(
      AppBootstrapConfig(
        navigatorKey: navigatorKey,
        app: App(navigatorKey: navigatorKey),
        configureDependencies: () async {},
        enableNotifications: false,
        startLocale: Locale('ar'),
        fallbackLocale: const Locale('ar'),
        supportedLocales: const <Locale>[
          AppDateTimeLocale.locale,
          Locale('ar'),
        ],
        translationsAssetPath: 'assets/translations',
      ),
    );
  });
}
