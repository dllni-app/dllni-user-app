import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_mode.dart';
import 'order_voting_mode_button.dart';

class GroupOrderModeSwitcher extends StatelessWidget {
  const GroupOrderModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final GroupOrderMode mode;
  final ValueChanged<GroupOrderMode> onModeChanged;

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
              title: 'الجلسات القائمة',
              isActive: mode == GroupOrderMode.existingGroups,
              onTap: () => onModeChanged(GroupOrderMode.existingGroups),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OrderVotingModeButton(
              title: 'إنشاء التصويت',
              isActive: mode == GroupOrderMode.create,
              onTap: () => onModeChanged(GroupOrderMode.create),
            ),
          ),
        ],
      ),
    );
  }
}
