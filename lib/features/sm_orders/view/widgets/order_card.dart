import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../../orders/view/screens/restaurant_order_tracking_screen.dart';
import '../../../orders/view/widgets/merchant_order_summary_card.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderResourceModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MerchantOrderSummaryCard(
      order: order,
      kind: MerchantOrderKind.supermarket,
      onTap: onTap,
      onTrack: () {
        context.pushRoute(
          '/restaurant-order-tracking',
          arguments: RestaurantOrderTrackingArgs(
            order: order,
            section: 'supermarket',
          ),
        );
      },
    );
  }
}
