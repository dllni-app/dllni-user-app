import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_tracking_colors.dart';

class TrackOrderAppBar extends StatelessWidget {
  const TrackOrderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: const Border(
          bottom: BorderSide(color: RestaurantOrderTrackingColors.orange, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), offset: const Offset(0, 1), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Icon(Icons.arrow_back, color: context.primary, size: 22),
            ),
          ),
          Expanded(
            child: AppText.titleLarge(
              'تتبع الطلب',
              color: RestaurantOrderTrackingColors.primary,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
