import 'package:flutter/material.dart';

import 'group_order_food_card.dart';
import 'group_order_food_row.dart';

class GroupOrderRequestedFoodsSection extends StatelessWidget {
  final List<GroupOrderFoodRow> foods;
  final void Function(GroupOrderFoodRow row)? onDelete;

  const GroupOrderRequestedFoodsSection({
    super.key,
    required this.foods,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: foods
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GroupOrderFoodCard(
                row: row,
                onDelete: onDelete == null ? null : () => onDelete!(row),
              ),
            ),
          )
          .toList(),
    );
  }
}
