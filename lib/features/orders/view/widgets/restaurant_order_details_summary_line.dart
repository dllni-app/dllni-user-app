import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderDetailsSummaryLine extends StatelessWidget {
  const RestaurantOrderDetailsSummaryLine({super.key, required this.label, required this.value, required this.emphasize});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.labelLarge(
          label,
          color: emphasize ? RestaurantOrderTrackingColors.primary : RestaurantOrderTrackingColors.grey,
          fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
        ),
        AppText.labelLarge(
          value,
          color: emphasize ? RestaurantOrderTrackingColors.primary : RestaurantOrderTrackingColors.grey,
          fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
        ),
      ],
    );
  }
}
