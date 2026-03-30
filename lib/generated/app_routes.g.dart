// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_discover_screen.dart';
import 'package:dllni_user_app/features/sm_home/view/screens/sm_home_screen.dart';
import 'package:dllni_user_app/features/sm_main_page.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_store_details_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      case '/discover':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmDiscoverScreen(selectedView: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/home':
        return MaterialPageRoute(
          builder: (_) => SmHomeScreen(),
          settings: settings,
        );
      case '/':
        if (args is int?) {
          return MaterialPageRoute(
            builder: (_) => SmMainPage(initialPage: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store':
        return MaterialPageRoute(
          builder: (_) => SmStoreDetailsScreen(),
          settings: settings,
        );

    }

    return null;
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route Error')),
      ),
      settings: settings,
    );
  }
}
