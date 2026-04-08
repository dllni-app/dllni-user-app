// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_details_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_late_time_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_discover_screen.dart';
import 'package:dllni_user_app/features/sm_favorite/view/screens/sm_favorite_screen.dart';
import 'package:dllni_user_app/features/sm_home/view/screens/sm_home_screen.dart';
import 'package:dllni_user_app/features/sm_main_page.dart';
import 'package:dllni_user_app/features/sm_offers/view/screens/sm_offers_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_details_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_tracking_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_product_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_store_details_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/cart_details':
        return MaterialPageRoute(
          builder: (_) => SmCartDetailsScreen(),
          settings: settings,
        );
      case '/cart':
        return MaterialPageRoute(
          builder: (_) => SmCartScreen(),
          settings: settings,
        );
      case '/late_time':
        return MaterialPageRoute(
          builder: (_) => SmLateTimeScreen(),
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
      case '/sm_favorite':
        return MaterialPageRoute(
          builder: (_) => SmFavoriteScreen(),
          settings: settings,
        );
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
      case '/sm_offers':
        return MaterialPageRoute(
          builder: (_) => SmOffersScreen(),
          settings: settings,
        );
      case '/order_details':
        return MaterialPageRoute(
          builder: (_) => SmOrderDetailsScreen(),
          settings: settings,
        );
      case '/order_tracking':
        return MaterialPageRoute(
          builder: (_) => SmOrderTrackingScreen(),
          settings: settings,
        );
      case '/product':
        if (args is SmProductDetailsScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => SmProductDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store':
        if (args is SmStoreDetailsScreenArgs?) {
          return MaterialPageRoute(
            builder: (_) => SmStoreDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);

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
