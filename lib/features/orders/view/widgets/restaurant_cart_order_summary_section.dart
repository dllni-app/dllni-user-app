import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_cart_card_wrapper.dart';
import 'restaurant_cart_summary_row.dart';

class RestaurantCartOrderSummarySection extends StatelessWidget {
  const RestaurantCartOrderSummarySection({
    super.key,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.money,
  });

  final int itemsCount;
  final double subtotal;
  final double discount;
  final double total;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    return RestaurantCartCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AppText.bodyLarge('ملخص الطلب', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RestaurantCartSummaryRow(
            title: 'مجموع المنتجات ($itemsCount عناصر)',
            value: '${subtotal.toStringAsFixed(1)} ل.س',
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            RestaurantCartSummaryRow(
              title: 'الخصم (كوبون)',
              value: '- ${discount.toStringAsFixed(1)} ل.س',
              valueColor: const Color(0xff10B981),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xffE5E7EB)),
          ),
          RestaurantCartSummaryRow(
            title: 'الإجمالي النهائي',
            value: '${total.toStringAsFixed(1)} ل.س',
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff1F2937),
            ),
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff1E2A78),
            ),
          ),
        ],
      ),
    );
  }
}
