import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/group_order_api_models.dart';
import 'group_order_food_card.dart';
import 'group_order_food_row.dart';

class GroupOrderCreatorParticipantsItemsSection extends StatelessWidget {
  final GroupOrderDetailsModel details;
  final List<GroupOrderMenuSectionItemModel> menuProducts;

  const GroupOrderCreatorParticipantsItemsSection({
    super.key,
    required this.details,
    required this.menuProducts,
  });

  String? _imageUrlForProduct(int? productId) {
    if (productId == null || productId <= 0) return null;
    for (final p in menuProducts) {
      if (p.id == productId) return p.primaryImageUrl;
    }
    return null;
  }

  String _sectionTypeForProduct(int? productId) {
    if (productId == null || productId <= 0) return 'غير مصنف';
    for (final p in menuProducts) {
      if (p.id == productId) {
        final t = p.sectionName.trim();
        return t.isEmpty ? 'غير مصنف' : t;
      }
    }
    return 'غير مصنف';
  }

  String _subtitleForItem(GroupOrderItemModel item) {
    final notes = (item.notes ?? '').trim();
    if (notes.isNotEmpty) return notes;
    final unit = item.unitPrice;
    if (unit != null) return 'السعر: $unit';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.participants.map((participant) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleSmall(participant.name ?? '-', fontWeight: FontWeight.w700),
              const SizedBox(height: 8),
              if (participant.items.isEmpty)
                AppText.bodySmall('لا توجد عناصر بعد', color: const Color(0xff9CA3AF))
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: participant.items.map((item) {
                    final imageUrl = item.imageUrl ?? _imageUrlForProduct(item.productId);
                    final row = GroupOrderFoodRow(
                      itemId: item.itemId,
                      productId: item.productId,
                      name: item.name ?? '-',
                      quantity: item.quantity,
                      type: _sectionTypeForProduct(item.productId),
                      subtitle: _subtitleForItem(item),
                      imageUrl: imageUrl,
                    );
                    return SizedBox(
                      width: 140,
                      height: 175,
                      child: GroupOrderFoodCard(row: row),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
