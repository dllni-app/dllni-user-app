// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_discover_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_products_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_reviews_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_category_products_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
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
