// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/auth/view/screens/register_screen.dart';
import 'package:dllni_user_app/features/main/view/screens/main_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/add_address_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/coupons_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_setup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_suggestions_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/my_addresses_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/notifications_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/order_voting_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/personal_details_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/shopping_list_details_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/shopping_list_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/vote_followup_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_discover_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_products_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_reviews_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_category_products_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_screen.dart';
import 'package:dllni_user_app/features/rs_main/view/rs_main_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(),
          settings: settings,
        );
      case '/main':
        if (args is int?) {
          return MaterialPageRoute(
            builder: (_) => MainScreen(returnedIndex: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/addaddress':
        if (args is MyAddressesScreenParams) {
          return MaterialPageRoute(
            builder: (_) => AddAddressScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/coupons':
        return MaterialPageRoute(
          builder: (_) => CouponsScreen(),
          settings: settings,
        );
      case '/luckyboxsetup':
        return MaterialPageRoute(
          builder: (_) => LuckyBoxSetupScreen(),
          settings: settings,
        );
      case '/luckyboxsuggestions':
        if (args is LuckyBoxSuggestionsArgs) {
          return MaterialPageRoute(
            builder: (_) => LuckyBoxSuggestionsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/myaddresses':
        if (args is bool) {
          return MaterialPageRoute(
            builder: (_) => MyAddressesScreen(selectMode: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationsScreen(),
          settings: settings,
        );
      case '/ordervoting':
        return MaterialPageRoute(
          builder: (_) => OrderVotingScreen(),
          settings: settings,
        );
      case '/personaldetails':
        if (args is PersonalDetailsParams) {
          return MaterialPageRoute(
            builder: (_) => PersonalDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/shopping_list':
        return MaterialPageRoute(
          builder: (_) => ShoppingListScreen(),
          settings: settings,
        );
      case '/shopping_list_details':
        return MaterialPageRoute(
          builder: (_) => ShoppingListDetailsScreen(),
          settings: settings,
        );
      case '/votefollowup':
        if (args is VoteFollowupScreenParams) {
          return MaterialPageRoute(
            builder: (_) => VoteFollowupScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
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
        if (args is StoreAllReviewsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllReviewsScreen(params: args),
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
      case '/rsmain':
        return MaterialPageRoute(
          builder: (_) => RsMainScreen(),
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
