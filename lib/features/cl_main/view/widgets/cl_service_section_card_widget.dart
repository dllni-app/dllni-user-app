import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Reusable booking card. Step display is decorative; the caller owns the flow.
class ClServiceSectionCardWidget extends StatelessWidget {
  const ClServiceSectionCardWidget({
    required this.title,
    required this.step,
    required this.child,
    this.subtitle,
    this.showStepBadge = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final int step;
  final Widget child;
  final bool showStepBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SharedPlatformColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: SharedPlatformColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (showStepBadge) ...[
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SharedPlatformColors.cleaningSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText.bodyMedium(
                      '$step',
                      color: SharedPlatformColors.cleaningInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyLarge(
                        title,
                        color: SharedPlatformColors.primary,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.start,
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        AppText.bodySmall(
                          subtitle!,
                          color: SharedPlatformColors.muted,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: SharedPlatformColors.border),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
