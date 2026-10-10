import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClMainServiceTabsWidget extends StatelessWidget {
  const ClMainServiceTabsWidget({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const int cleaningIndex = 0;
  static const int occasionsIndex = 1;
  static const int hourlyIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: SharedPlatformColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharedPlatformColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ServiceTabItem(
              key: const Key('cl_main_cleaning_tab'),
              label: 'التنظيفات',
              isSelected: selectedIndex == cleaningIndex,
              onTap: () => onChanged(cleaningIndex),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ServiceTabItem(
              key: const Key('cl_main_occasions_tab'),
              label: 'المناسبات',
              isSelected: selectedIndex == occasionsIndex,
              onTap: () => onChanged(occasionsIndex),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ServiceTabItem(
              key: const Key('cl_main_hourly_tab'),
              label: 'عامل بالساعة',
              isSelected: selectedIndex == hourlyIndex,
              onTap: () => onChanged(hourlyIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTabItem extends StatelessWidget {
  const _ServiceTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? SharedPlatformColors.primary
            : SharedPlatformColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AppText.labelLarge(
              label,
              color: isSelected ? Colors.white : SharedPlatformColors.muted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
