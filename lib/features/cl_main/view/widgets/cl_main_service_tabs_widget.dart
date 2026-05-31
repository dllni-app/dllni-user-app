import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          const SizedBox(width: 8),
          Expanded(
            child: _ServiceTabItem(
              key: const Key('cl_main_occasions_tab'),
              label: 'المناسبات',
              isSelected: selectedIndex == occasionsIndex,
              onTap: () => onChanged(occasionsIndex),
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

  static const LinearGradient _selectedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF1E2A78), Color(0xFF4A5FCF)],
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected ? _selectedGradient : null,
          color: isSelected ? context.primary : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: AppText.labelLarge(
            label,
            color: isSelected ? context.onPrimary : const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
