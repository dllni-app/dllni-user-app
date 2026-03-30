// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_restaurant_detail_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_my_addresses_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_notifications_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_order_voting_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_personal_details_screen.dart';
import 'package:dllni_user_app/features/rs_profile/view/screens/rs_vote_followup_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/rsrestaurantdetail':
        if (args is RsRestaurantDetailParams) {
          return MaterialPageRoute(
            builder: (_) => RsRestaurantDetailScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rsmyaddresses':
        return MaterialPageRoute(
          builder: (_) => RsMyAddressesScreen(),
          settings: settings,
        );
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
        return MaterialPageRoute(
          builder: (_) => RsVoteFollowupScreen(),
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
