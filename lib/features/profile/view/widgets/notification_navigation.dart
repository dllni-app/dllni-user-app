import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/view/screens/cleaning_order_details_screen.dart';

void tryNavigateFromNotificationPayload(
  BuildContext context, {
  required String? module,
  required Map<String, dynamic>? data,
}) {
  if (data == null || data.isEmpty) return;
  final m = (module ?? '').toLowerCase();
  if (m == 'cleaning') {
    final orderId = _intFromData(data, const ['bookingId', 'booking_id', 'orderId', 'order_id']);
    if (orderId != null) {
      context.pushRoute(
        '/cleaning-order-details',
        arguments: CleaningOrderDetailsArgs(orderId: orderId),
      );
    }
  }
}

int? _intFromData(Map<String, dynamic> data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v == null) continue;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
  }
  return null;
}
