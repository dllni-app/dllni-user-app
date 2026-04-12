// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/auth/view/screens/register_screen.dart';
import 'package:dllni_user_app/features/main/view/screens/main_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/restaurant_order_fulfillment_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/restaurant_order_tracking_screen.dart';
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
import 'package:dllni_user_app/features/rs_favourite/view/screens/rs_favourite_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_category_products_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_screen.dart';
import 'package:dllni_user_app/features/rs_main/view/rs_main_screen.dart';
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

import '../features/profile/data/models/shopping_lists_api_models.dart';

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
      case '/restaurant-order-fulfillment':
        if (args is RestaurantOrderFulfillmentArgs) {
          return MaterialPageRoute(
            builder: (_) => RestaurantOrderFulfillmentScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/restaurant-order-tracking':
        if (args is RestaurantOrderTrackingArgs) {
          return MaterialPageRoute(
            builder: (_) => RestaurantOrderTrackingScreen(args: args),
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
      case '/shopping_list_details':
        if (args is ShoppingListDetailsArgs) {
          return MaterialPageRoute(
            builder: (_) => ShoppingListDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/shopping_list':
        return MaterialPageRoute(
          builder: (_) => ShoppingListScreen(),
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
      case '/rs_discover':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => RsDiscoverScreen(selectedView: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_product':
        if (args is ProductDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsProductDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store-all-products':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllProductsScreen(restaurantId: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store-all-reviews':
        if (args is StoreAllReviewsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllReviewsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store':
        if (args is StoreDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsStoreDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rsfavourite':
        return MaterialPageRoute(
          builder: (_) => RsFavouriteScreen(),
          settings: settings,
        );
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
      case '/sm_discover':
        if (args is SmDiscoverScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmDiscoverScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/sm_favorite':
        return MaterialPageRoute(
          builder: (_) => SmFavoriteScreen(),
          settings: settings,
        );
      case '/sm_home':
        return MaterialPageRoute(
          builder: (_) => SmHomeScreen(),
          settings: settings,
        );
      case '/smmain':
        if (args is SmMainScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmMainPage(params: args),
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
        if (args is SmOrderDetailsScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => SmOrderDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
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
