import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// V7 booking panel: restrained, content-first, without legacy step badges.
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE7EBF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: SharedPlatformColors.primary,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
