import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderEtaCard extends StatelessWidget {
  const RestaurantOrderEtaCard({super.key, required this.etaText});

  final String etaText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        spacing: 8,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xffEFF6FF),
            radius: 30,
            child: Icon(Icons.access_time_filled_outlined, color: context.primary, size: 28),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge('الوقت المتوقع للوصول', color: RestaurantOrderTrackingColors.grey),
                const SizedBox(height: 6),
                AppText.titleSmall(etaText, color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
