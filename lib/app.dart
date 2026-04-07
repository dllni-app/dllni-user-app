import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/rs_main/view/rs_main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'دللني',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home:
          SharedPreferencesHelper.getData(key: 'token') != null &&
              SharedPreferencesHelper.getData(key: 'token') != ''
          ? const RsMainScreen()
          : const LoginScreen(),
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
          onSurface: Color(0xffFFFFFF),
          primaryContainer: Color(0xffFF7A00),
          onPrimaryContainer: Color(0xffFFFFFF),
        ),
      ),
    );
  }
}
