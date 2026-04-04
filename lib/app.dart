import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'features/main/view/screens/main_screen.dart';

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
      home: const MainScreen(),
      theme: ThemeData(
        fontFamily: 'cairo'
      ),
    );
  }
}
