import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Estimates are display-only; numbers are always provided by the existing flow.
class ClServiceGradientInfoCardWidget extends StatelessWidget {
  const ClServiceGradientInfoCardWidget({
    required this.estimatedSqm,
    required this.estimatedHours,
    this.showEstimatedSqm = true,
    super.key,
  });

  final int estimatedSqm;
  final double estimatedHours;
  final bool showEstimatedSqm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharedPlatformColors.cleaningSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: SharedPlatformColors.cleaning.withValues(alpha: .22),
        ),
      ),
      child: Column(
        children: [
          if (showEstimatedSqm) ...[
            _InfoRowWidget(
              title: 'المساحة التقريبية لمنزلك',
              value: '$estimatedSqm م2',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 14),
          ],
          _InfoRowWidget(
            title: 'عدد ساعات العمل المتوقعة',
            value: '${estimatedHours.toStringAsFixed(1)} ساعات عمل',
            icon: Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }
}

class _InfoRowWidget extends StatelessWidget {
  const _InfoRowWidget({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: SharedPlatformColors.cleaningInk, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.bodySmall(
            title,
            color: SharedPlatformColors.ink,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AppText.bodySmall(
            value,
            color: SharedPlatformColors.primary,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
