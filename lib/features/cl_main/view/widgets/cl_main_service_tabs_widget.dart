import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system/design_system.dart';

/// Compact V6 discovery navigation. Indexes/routes preserved for existing flow.
class ClMainServiceTabsWidget extends StatelessWidget {
  const ClMainServiceTabsWidget({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  static const int cleaningIndex = 0;
  static const int occasionsIndex = 1;
  static const int hourlyIndex = 2;

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _DiscoveryTab(
          key: const Key('cl_main_cleaning_tab'),
          title: 'التنظيفات',
          icon: Icons.cleaning_services_outlined,
          selected: selectedIndex == cleaningIndex,
          onTap: () => onChanged(cleaningIndex),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _DiscoveryTab(
          key: const Key('cl_main_occasions_tab'),
          title: 'المناسبات',
          icon: Icons.celebration_outlined,
          selected: selectedIndex == occasionsIndex,
          onTap: () => onChanged(occasionsIndex),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _DiscoveryTab(
          key: const Key('cl_main_hourly_tab'),
          title: 'بالساعة',
          icon: Icons.schedule_outlined,
          selected: selectedIndex == hourlyIndex,
          onTap: () => onChanged(hourlyIndex),
        ),
      ),
    ],
  );
}

class _DiscoveryTab extends StatelessWidget {
  const _DiscoveryTab({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: title,
    child: Material(
      color: selected ? AppSection.cleaning.soft : AlnadhaTokens.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppSection.cleaning.accent
                  : AlnadhaTokens.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppSection.cleaning.ink : AlnadhaTokens.muted,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AlnadhaTokens.caption.copyWith(
                  color: selected
                      ? AppSection.cleaning.ink
                      : AlnadhaTokens.muted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
