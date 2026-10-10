import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceDayPreviewCardWidget extends StatelessWidget {
  const ClServiceDayPreviewCardWidget({
    required this.dayAr,
    required this.dayDate,
    super.key,
  });

  final String dayAr;
  final String dayDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SharedPlatformColors.cleaningSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: SharedPlatformColors.cleaningInk,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleMedium(
                dayAr,
                color: SharedPlatformColors.primary,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 2),
              AppText.bodySmall(
                dayDate,
                color: SharedPlatformColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
