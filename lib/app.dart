import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'core/di/injection.dart';
import 'core/realtime/cleaning_booking_pusher_service.dart';
import 'core/realtime/cleaning_global_verification_gate_coordinator.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_colors.dart';
import 'features/main/view/screens/main_screen.dart';
import 'features/splash/view/screens/splash_screen.dart';

class App extends StatefulWidget {
  const App({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final CleaningGlobalVerificationGateCoordinator _verificationCoordinator;
  bool _didOpenMainScreen = false;

  @override
  void initState() {
    super.initState();
    unawaited(getIt<CleaningBookingPusherService>().ensureInitialized());
    _verificationCoordinator = CleaningGlobalVerificationGateCoordinator(
      navigatorKey: widget.navigatorKey,
    );
  }

  @override
  void dispose() {
    unawaited(_verificationCoordinator.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        navigatorKey: widget.navigatorKey,
        title: 'دللني',
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: SplashScreen(onFinished: _openMainScreen),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final clampedScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.2,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: ThemeData(
          fontFamily: 'cairo',
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(
              color: AppColors.hintText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          colorScheme: const ColorScheme(
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
      ),
    );
  }

  void _openMainScreen() {
    if (_didOpenMainScreen) return;
    _didOpenMainScreen = true;

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openMainScreen());
      _didOpenMainScreen = false;
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
    );
    unawaited(_verificationCoordinator.start());
  }
}
