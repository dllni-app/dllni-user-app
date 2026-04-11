import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';
import 'restaurant_order_details_line_item.dart';
import 'restaurant_order_details_summary_line.dart';
import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderDetailsCard extends StatelessWidget {
  const RestaurantOrderDetailsCard({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.money,
  });

  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleSmall('تفاصيل الطلب', color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
          const SizedBox(height: 12),
          if (items.isEmpty)
            AppText.bodyMedium('لا عناصر', color: RestaurantOrderTrackingColors.grey)
          else
            ...items.map((e) => RestaurantOrderDetailsLineItem(item: e, money: money)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xffE5E7EB)),
          ),
          RestaurantOrderDetailsSummaryLine(label: 'المجموع الفرعي', value: money(subtotal), emphasize: false),
          const SizedBox(height: 8),
          RestaurantOrderDetailsSummaryLine(label: 'رسوم التوصيل', value: money(deliveryFee), emphasize: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xffE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.bodyMedium('الإجمالي', color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
              AppText.bodyMedium(money(total), color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
