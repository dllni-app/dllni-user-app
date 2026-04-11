import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';

class RestaurantOrderCard extends StatelessWidget {
  const RestaurantOrderCard({super.key, required this.order, required this.onTap});

  final OrderResourceModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemsPreview = order.items.map((item) => '${item.name ?? ''} (×${item.quantity})').join(' - ');
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB), width: 1),
          color: context.onPrimary,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), offset: const Offset(0, 1), blurRadius: 2)],
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.titleSmall(order.orderNumber ?? 'الطلبية الحالية', color: Colors.black, fontWeight: FontWeight.bold),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xff1E2A78)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge('المطعم:', color: const Color(0xff1F2937), fontWeight: FontWeight.w500),
                Expanded(
                  child: AppText.labelLarge(
                    order.merchant?.name ?? '-',
                    color: const Color(0xff6B7280),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge('الطلبات:', color: const Color(0xff1F2937), fontWeight: FontWeight.w500),
                Expanded(
                  child: AppText.labelLarge(
                    itemsPreview.isEmpty ? '-' : itemsPreview,
                    color: const Color(0xff6B7280),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
