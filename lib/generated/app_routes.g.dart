// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_home_description_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_service_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_worker_profile_detail_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_worker_reviews_all_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/clmainhomedescription':
        return MaterialPageRoute(
          builder: (_) => ClMainHomeDescriptionScreen(),
          settings: settings,
        );
      case '/clmain':
        return MaterialPageRoute(
          builder: (_) => ClMainScreen(),
          settings: settings,
        );
      case '/clmainserviceschedule':
        return MaterialPageRoute(
          builder: (_) => ClMainServiceScheduleScreen(),
          settings: settings,
        );
      case '/clworkerprofiledetail':
        if (args is WorkerProfileRouteArgs) {
          return MaterialPageRoute(
            builder: (_) => ClWorkerProfileDetailScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clworkerreviewsall':
        if (args is WorkerProfileRouteArgs) {
          return MaterialPageRoute(
            builder: (_) => ClWorkerReviewsAllScreen(args: args),
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
