import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_food_row.dart';
import 'group_order_selected_products_formatter.dart';

class GroupOrderRequestedFoodsSection extends StatelessWidget {
  final List<GroupOrderFoodRow> foods;
  final String memberName;

  const GroupOrderRequestedFoodsSection({
    super.key,
    required this.foods,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return AppText.bodySmall(
        'لم تضف أي أطعمة بعد',
        color: const Color(0xff9CA3AF),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleSmall(memberName, fontWeight: FontWeight.w700),
        const SizedBox(height: 8),
        AppText.bodyMedium(
          GroupOrderSelectedProductsFormatter.formatFromRows(foods),
          color: const Color(0xff4B5563),
        ),
      ],
    );
  }
}
