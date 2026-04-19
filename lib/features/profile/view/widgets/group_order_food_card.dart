import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_food_row.dart';

class GroupOrderFoodCard extends StatelessWidget {
  final GroupOrderFoodRow row;
  final VoidCallback? onDelete;

  const GroupOrderFoodCard({
    super.key,
    required this.row,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Color(0xffEF4444)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleSmall(row.name, fontWeight: FontWeight.w700),
                const SizedBox(height: 4),
                AppText.bodySmall('الكمية ${row.quantity}', color: const Color(0xff6B7280)),
                if (row.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText.bodySmall(row.subtitle, color: const Color(0xff9CA3AF)),
                ],
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage.network(
              row.imageUrl ?? '',
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
