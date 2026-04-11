import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderBottomActionRow extends StatelessWidget {
  const RestaurantOrderBottomActionRow({super.key, required this.onSupportChat, required this.onHelp});

  final VoidCallback onSupportChat;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSupportChat,
            style: OutlinedButton.styleFrom(
              foregroundColor: RestaurantOrderTrackingColors.primary,
              side: const BorderSide(color: RestaurantOrderTrackingColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            label: AppText.labelLarge('محادثة الدعم', color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onHelp,
            style: OutlinedButton.styleFrom(
              foregroundColor: RestaurantOrderTrackingColors.primary,
              side: const BorderSide(color: RestaurantOrderTrackingColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.info_outline, size: 20),
            label: AppText.labelLarge('مساعدة', color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
