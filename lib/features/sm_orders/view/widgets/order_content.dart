import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../../../core/themes/app_colors.dart';

class OrderContent extends StatelessWidget {
  const OrderContent({super.key, required this.items});
  final List<OrderItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          AppText(
            "محتويات الطلب",
            style: TextStyle(
              color: Color(0xFF1E2B5E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 24 / 16,
            ),
          ),
          if (items.isEmpty)
            AppText('لا توجد عناصر في هذا الطلب', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))
          else
            ...items.map(
              (item) => _OrderContentRow(
                quantity: item.quantity,
                name: item.name ?? '-',
                price: item.totalPrice,
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderContentRow extends StatelessWidget {
  const _OrderContentRow({
    required this.quantity,
    required this.name,
    required this.price,
  });
  final int quantity;
  final String name;
  final num price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        spacing: 16,
        children: [
          AppText(
            "x$quantity",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
          Expanded(
            child: AppText(
              name,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ),
          AppText(
            "$price ل.س",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
