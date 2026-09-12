import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 14),
        child: Column(
          children: [
            Row(
              children: [
                if (showStepBadge) ...[
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: colors.primary,
                    child: AppText.bodyMedium(
                      '$step',
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.headlineSmall(
                        title,
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.start,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AppText.bodySmall(
                          subtitle!,
                          color: colors.onSurfaceVariant,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: colors.outlineVariant, thickness: 1),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
