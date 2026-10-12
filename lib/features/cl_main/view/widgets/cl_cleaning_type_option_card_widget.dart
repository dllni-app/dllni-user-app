import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// V6 direct cleaning-mode selection; callback still updates original draft.
class ClCleaningTypeOptionCardWidget extends StatelessWidget {
  const ClCleaningTypeOptionCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deep = title.contains('عميق') || title.toLowerCase().contains('deep');
    return Semantics(
      selected: isSelected,
      button: true,
      label: title,
      child: AppSurfaceCard(
        section: AppSection.cleaning,
        selected: isSelected,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppSection.cleaning.soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                deep
                    ? Icons.auto_awesome_outlined
                    : Icons.cleaning_services_outlined,
                color: AppSection.cleaning.ink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AlnadhaTokens.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppSection.cleaning.ink : AlnadhaTokens.muted,
            ),
          ],
        ),
      ),
    );
  }
}
