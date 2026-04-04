// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_discover_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_products_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_reviews_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_category_products_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_screen.dart';
import 'package:dllni_user_app/features/rs_orders/view/screens/rs_order_edit_screen.dart';
import 'package:dllni_user_app/features/rs_orders/view/screens/rs_order_fulfillment_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_favorite_restaurants_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_my_addresses_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_notifications_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_order_voting_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_personal_details_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_vote_followup_screen.dart';

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
            builder: (_) => RsDiscoverScreen(selectedView: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/product':
        if (args is ProductDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmProductDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store-all-products':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllProductsScreen(restaurantId: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store-all-reviews':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllReviewsScreen(restaurantId: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store':
        if (args is StoreDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmStoreDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rshomecategoryproducts':
        if (args is RsHomeCategoryProductsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsHomeCategoryProductsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/home':
        return MaterialPageRoute(
          builder: (_) => RsHomeScreen(),
          settings: settings,
        );
      case '/rsorderedit':
        return MaterialPageRoute(
          builder: (_) => RsOrderEditScreen(),
          settings: settings,
        );
      case '/rsorderfulfillment':
        return MaterialPageRoute(
          builder: (_) => RsOrderFulfillmentScreen(),
          settings: settings,
        );
      case '/rsfavoriterestaurants':
        return MaterialPageRoute(
          builder: (_) => RsFavoriteRestaurantsScreen(),
          settings: settings,
        );
      case '/rsmyaddresses':
        if (args is bool) {
          return MaterialPageRoute(
            builder: (_) => RsMyAddressesScreen(selectMode: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rsnotifications':
        return MaterialPageRoute(
          builder: (_) => RsNotificationsScreen(),
          settings: settings,
        );
      case '/rsordervoting':
        return MaterialPageRoute(
          builder: (_) => RsOrderVotingScreen(),
          settings: settings,
        );
      case '/rspersonaldetails':
        if (args is RsPersonalDetailsParams) {
          return MaterialPageRoute(
            builder: (_) => RsPersonalDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rsvotefollowup':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => RsVoteFollowupScreen(voteId: args),
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
