import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceDayPreviewCardWidget extends StatelessWidget {
  const ClServiceDayPreviewCardWidget({required this.dayAr, required this.dayEn, super.key});

  final String dayAr;
  final String dayEn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: const Color(0xFFDCE0EA), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF1E2A78)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleMedium(dayAr, color: const Color(0xFF151E43), fontWeight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText.bodySmall(dayEn, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
            ],
          ),
        ),
      ],
    );
  }
}
