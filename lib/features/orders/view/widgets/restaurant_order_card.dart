import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';
import '../screens/restaurant_order_tracking_screen.dart';
import 'merchant_order_summary_card.dart';

class RestaurantOrderCard extends StatelessWidget {
  const RestaurantOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.merchantLabel = 'المطعم:',
  });

  final OrderResourceModel order;
  final VoidCallback onTap;

  // Kept for backwards compatibility with existing call sites.
  final String merchantLabel;

  @override
  Widget build(BuildContext context) {
    return MerchantOrderSummaryCard(
      order: order,
      kind: MerchantOrderKind.restaurant,
      onTap: onTap,
      onTrack: () {
        context.pushRoute(
          '/restaurant-order-tracking',
          arguments: RestaurantOrderTrackingArgs(
            order: order,
            section: 'restaurant',
          ),
        );
      },
    );
  }
}
