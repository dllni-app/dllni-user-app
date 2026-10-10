import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClOptionTileWidget extends StatelessWidget {
  const ClOptionTileWidget({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: value
          ? SharedPlatformColors.cleaningSoft
          : SharedPlatformColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: value
              ? SharedPlatformColors.cleaning
              : SharedPlatformColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (next) => onChanged(next ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                activeColor: SharedPlatformColors.primary,
                checkColor: Colors.white,
                side: const BorderSide(
                  color: SharedPlatformColors.border,
                  width: 1.4,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      title,
                      textAlign: TextAlign.start,
                      color: SharedPlatformColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      AppText.bodySmall(
                        subtitle!,
                        textAlign: TextAlign.start,
                        color: SharedPlatformColors.muted,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
