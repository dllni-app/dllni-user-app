import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/group_order_api_models.dart';
import 'group_order_selected_products_formatter.dart';

class GroupOrderCreatorParticipantsItemsSection extends StatelessWidget {
  final GroupOrderDetailsModel details;

  const GroupOrderCreatorParticipantsItemsSection({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.participants.indexed.map((entry) {
        final index = entry.$1;
        final participant = entry.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleSmall(
                '${index + 1}- ${participant.name ?? '-'}',
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              if (participant.items.isEmpty)
                AppText.bodySmall(
                  'لا توجد عناصر بعد',
                  color: const Color(0xff9CA3AF),
                )
              else
                AppText.bodyMedium(
                  GroupOrderSelectedProductsFormatter.formatFromItems(
                    participant.items,
                  ),
                  color: const Color(0xff4B5563),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
