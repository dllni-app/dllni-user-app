import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

class CleaningTeamSearchBannerWidget extends StatelessWidget {
  const CleaningTeamSearchBannerWidget({
    required this.acceptance,
    required this.numberOfWorkers,
    super.key,
  });

  final CleaningWorkerAcceptanceModel? acceptance;
  final int? numberOfWorkers;

  @override
  Widget build(BuildContext context) {
    final required = acceptance?.required ?? numberOfWorkers ?? 0;
    final accepted = acceptance?.accepted ?? 0;
    final remaining = acceptance?.remaining ?? (required - accepted);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A78), Color(0xFF0CBBC7)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodyMedium(
                  'جاري البحث عن عمال',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (required > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText.bodySmall(
                    '$accepted / $required',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppText.bodySmall(
            remaining > 0
                ? 'تم قبول $accepted عامل. بانتظار $remaining عامل إضافي.'
                : 'يتم تجميع الفريق المطلوب للخدمة.',
            color: Colors.white.withValues(alpha: 0.92),
            textAlign: TextAlign.right,
          ),
          if (required > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: required > 0 ? (accepted / required).clamp(0.0, 1.0) : 0,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CleaningPreferredWorkerFallbackBannerWidget extends StatelessWidget {
  const CleaningPreferredWorkerFallbackBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF2B94B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB76E00),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.bodyMedium(
              'رفض العامل المخصص الطلب. تم تحويل طلبك إلى طلب عام ونبحث الآن عن عامل بديل.',
              color: const Color(0xFF7A4B00),
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
