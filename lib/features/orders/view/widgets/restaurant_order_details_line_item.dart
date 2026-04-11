import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';
import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderDetailsLineItem extends StatelessWidget {
  const RestaurantOrderDetailsLineItem({super.key, required this.item, required this.money});

  final OrderItemModel item;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final note = item.note;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: AppText.labelMedium('${item.quantity}x', color: RestaurantOrderTrackingColors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText.labelLarge(
                        item.name ?? '—',
                        color: const Color(0xff111827),
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText.labelMedium(note, color: RestaurantOrderTrackingColors.grey, textAlign: TextAlign.start),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppText.labelLarge(money(item.totalPrice), color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
