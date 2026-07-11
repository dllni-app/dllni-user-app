import 'package:flutter/material.dart';

import '../../features/orders/view/screens/cleaning_order_details_screen.dart';
import '../../generated/app_routes.g.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == 'cleaning_order_details') {
      final orderId = _cleaningOrderId(settings.arguments);
      if (orderId == null) {
        return _errorRoute(settings);
      }

      return MaterialPageRoute(
        builder: (_) => CleaningOrderDetailsScreen(
          args: CleaningOrderDetailsArgs(orderId: orderId),
        ),
        settings: settings,
      );
    }

    return GeneratedAppRoutes.onGenerateRoute(settings);
  }

  static int? _cleaningOrderId(Object? arguments) {
    if (arguments is CleaningOrderDetailsArgs) {
      return arguments.orderId;
    }

    if (arguments is! Map) {
      return null;
    }

    for (final key in const ['bookingId', 'booking_id', 'orderId', 'order_id']) {
      final value = arguments[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Unable to open cleaning order')),
      ),
      settings: settings,
    );
  }
}
