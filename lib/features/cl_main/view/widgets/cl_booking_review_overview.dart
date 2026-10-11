import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import 'cl_service_section_card_widget.dart';

/// A customer-readable snapshot of the draft. This widget does not calculate
/// pricing or change booking data; the price remains backend-authoritative.
class ClBookingReviewOverview extends StatelessWidget {
  const ClBookingReviewOverview({
    super.key,
    required this.service,
    required this.address,
    required this.workerLabel,
    required this.materialsRequested,
    required this.services,
    this.recurring = false,
  });

  final String service;
  final String address;
  final String workerLabel;
  final bool materialsRequested;
  final List<String> services;
  final bool recurring;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      title: 'راجع تفاصيل الحجز',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewLine(label: 'نوع التنظيف', value: service),
          const SizedBox(height: 10),
          _ReviewLine(label: 'العنوان', value: address),
          const SizedBox(height: 10),
          _ReviewLine(label: 'العمال', value: workerLabel),
          const SizedBox(height: 10),
          _ReviewLine(
            label: 'مواد التنظيف',
            value: materialsRequested ? 'إحضار مواد التنظيف' : 'دون طلب مواد',
          ),
          if (recurring) ...[
            const SizedBox(height: 10),
            const _ReviewLine(label: 'نوع الحجز', value: 'حجز متكرر'),
          ],
          if (services.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'الخدمات الإضافية المختارة',
              style: TextStyle(
                fontSize: 13,
                color: SharedPlatformColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in services)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: SharedPlatformColors.cleaningSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SharedPlatformColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 102,
          child: Text(
            label,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
