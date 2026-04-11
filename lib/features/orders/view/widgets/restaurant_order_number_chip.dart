import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderNumberChip extends StatelessWidget {
  const RestaurantOrderNumberChip({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: AppText.titleSmall(
        'طلب #$orderNumber',
        color: RestaurantOrderTrackingColors.orange,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
