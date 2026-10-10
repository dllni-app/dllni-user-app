import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClCleaningTypeOptionCardWidget extends StatelessWidget {
  const ClCleaningTypeOptionCardWidget({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF0F3FC)
                  : SharedPlatformColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? SharedPlatformColors.primary
                    : SharedPlatformColors.border,
                width: isSelected ? 1.7 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? SharedPlatformColors.primary
                      : SharedPlatformColors.muted,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyMedium(
                        title,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.start,
                        color: SharedPlatformColors.ink,
                      ),
                      const SizedBox(height: 4),
                      AppText.labelLarge(
                        subtitle,
                        textAlign: TextAlign.start,
                        color: SharedPlatformColors.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
