import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/realtime/cleaning_booking_pusher_service.dart';
import 'core/realtime/cleaning_global_verification_gate_coordinator.dart';
import 'core/routes/app_router.dart';
import 'core/session/user_session_keys.dart';
import 'core/session/user_session_prefs.dart';
import 'features/auth/view/screens/login_screen.dart';
import 'features/main/view/screens/main_screen.dart';

class App extends StatefulWidget {
  const App({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final CleaningGlobalVerificationGateCoordinator _verificationCoordinator;
  late final bool _hasSavedToken;

  @override
  void initState() {
    super.initState();
    _hasSavedToken = UserSessionPrefs.readString(UserSessionKeys.token) != null;
    unawaited(getIt<CleaningBookingPusherService>().ensureInitialized());
    _verificationCoordinator = CleaningGlobalVerificationGateCoordinator(
      navigatorKey: widget.navigatorKey,
    );
    unawaited(_verificationCoordinator.start());
  }

  @override
  void dispose() {
    unawaited(_verificationCoordinator.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'دللني',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: _hasSavedToken ? const MainScreen() : const LoginScreen(),
      theme: ThemeData(
        fontFamily: 'cairo',
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff1E2A78),
          onPrimary: Color(0xffFFFFFF),
          secondary: Color(0xff6C63FF),
          onSecondary: Color(0xffFFFFFF),
          error: Color(0xffBF393D),
          onError: Color(0xffFFFFFF),
          surface: Color(0xffF0F0F0),
          onSurface: Colors.black,
          primaryContainer: Color(0xffFF7A00),
          onPrimaryContainer: Color(0xffFFFFFF),
        ),
      ),
    );
  }
}
