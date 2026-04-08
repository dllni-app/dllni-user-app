import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'order_voting_mode.dart';
import 'order_voting_mode_button.dart';

class OrderVotingModeSwitcher extends StatelessWidget {
  const OrderVotingModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final OrderVotingMode mode;
  final ValueChanged<OrderVotingMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: OrderVotingModeButton(
              title: 'المقارنات القائمة',
              isActive: mode == OrderVotingMode.existingPolls,
              onTap: () => onModeChanged(OrderVotingMode.existingPolls),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OrderVotingModeButton(
              title: 'إنشاء التصويت',
              isActive: mode == OrderVotingMode.create,
              onTap: () => onModeChanged(OrderVotingMode.create),
            ),
          ),
        ],
      ),
    );
  }
}
