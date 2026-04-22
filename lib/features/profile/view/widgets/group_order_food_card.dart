import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_food_row.dart';

class GroupOrderFoodCard extends StatelessWidget {
  final GroupOrderFoodRow row;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const GroupOrderFoodCard({super.key, required this.row, this.onDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
        color: Colors.white,
      ),
      width: 140,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: AppImage.network(row.imageUrl ?? '', height: 80, fit: BoxFit.cover, borderRadius: BorderRadius.circular(16))),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMedium(row.name, fontWeight: FontWeight.w700, scrollText: true),
              if ((row.sizeLabel ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                AppText.labelSmall('الحجم: ${row.sizeLabel}', color: const Color(0xff6B7280)),
              ],
              if (row.subtitle.isNotEmpty) ...[const SizedBox(height: 4), AppText.labelSmall(row.subtitle, color: const Color(0xff6B7280))],
              if (row.quantity > 0) ...[const SizedBox(height: 4), AppText.labelSmall('الكمية: ${row.quantity}', color: const Color(0xff9CA3AF))],
              if (onDelete != null) ...[
                const SizedBox(height: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Color(0xffEF4444), size: 22),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}
