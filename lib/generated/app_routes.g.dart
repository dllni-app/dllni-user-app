// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/main/view/screens/main_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_setup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_suggestions_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/my_addresses_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/notifications_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/order_voting_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/personal_details_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/vote_followup_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/main':
        if (args is int?) {
          return MaterialPageRoute(
            builder: (_) => MainScreen(returnedIndex: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/luckyboxsetup':
        return MaterialPageRoute(
          builder: (_) => LuckyBoxSetupScreen(),
          settings: settings,
        );
      case '/luckyboxsuggestions':
        return MaterialPageRoute(
          builder: (_) => LuckyBoxSuggestionsScreen(),
          settings: settings,
        );
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
      case '/votefollowup':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => VoteFollowupScreen(voteId: args),
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
