// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_details_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_late_time_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_discover_screen.dart';
import 'package:dllni_user_app/features/sm_home/view/screens/sm_home_screen.dart';
import 'package:dllni_user_app/features/sm_main_page.dart';
import 'package:dllni_user_app/features/sm_offers/view/screens/sm_offers_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_details_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_tracking_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_address_details_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_address_map_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_favorite_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_my_addresses_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_notifications_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_order_voting_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_personal_details_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_shopping_list_details_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_shopping_list_screen.dart';
import 'package:dllni_user_app/features/sm_profile/view/screens/sm_vote_followup_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_product_details_screen.dart';
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
            builder: (_) => SmDiscoverScreen(selectedView: selectedView, expandSearch: expandSearch),
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
            builder: (_) => SmMainPage(initialPage: initialPage, expandSearch: expandSearch),
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
      case '/sm_address_details':
        return MaterialPageRoute(
          builder: (_) => SmAddressDetailsScreen(),
          settings: settings,
        );
      case '/sm_address_map':
        return MaterialPageRoute(
          builder: (_) => SmAddressMapScreen(),
          settings: settings,
        );
      case '/sm_favorite':
        return MaterialPageRoute(
          builder: (_) => SmFavoriteScreen(),
          settings: settings,
        );
      case '/sm_my_addresses':
        return MaterialPageRoute(
          builder: (_) => SmMyAddressesScreen(),
          settings: settings,
        );
      case '/sm_notification':
        return MaterialPageRoute(
          builder: (_) => SmNotificationsScreen(),
          settings: settings,
        );
      case '/smordervoting':
        return MaterialPageRoute(
          builder: (_) => SmOrderVotingScreen(),
          settings: settings,
        );
      case '/sm_personal_details':
        if (args is SmPersonalDetailsParams) {
          return MaterialPageRoute(
            builder: (_) => SmPersonalDetailsScreen(params: params),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/sm_shopping_list_details':
        return MaterialPageRoute(
          builder: (_) => SmShoppingListDetailsScreen(),
          settings: settings,
        );
      case '/sm_shopping_list':
        return MaterialPageRoute(
          builder: (_) => SmShoppingListScreen(),
          settings: settings,
        );
      case '/smvotefollowup':
        return MaterialPageRoute(
          builder: (_) => SmVoteFollowupScreen(),
          settings: settings,
        );
      case '/product':
        return MaterialPageRoute(
          builder: (_) => SmProductDetailsScreen(),
          settings: settings,
        );
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
