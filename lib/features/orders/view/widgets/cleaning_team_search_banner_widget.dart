import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

class CleaningTeamSearchBannerWidget extends StatelessWidget {
  const CleaningTeamSearchBannerWidget({
    required this.acceptance,
    required this.numberOfWorkers,
    this.isHotOrder = false,
    super.key,
  });

  final CleaningWorkerAcceptanceModel? acceptance;
  final int? numberOfWorkers;
  final bool isHotOrder;

  @override
  Widget build(BuildContext context) {
    final hasAcceptedWorker = (acceptance?.accepted ?? 0) > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharedPlatformColors.cleaningSoft,
        border: Border.all(color: const Color(0xFFB9E8EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasAcceptedWorker
                ? Icons.verified_outlined
                : isHotOrder
                ? Icons.flash_on_outlined
                : Icons.hourglass_top_rounded,
            color: SharedPlatformColors.cleaningInk,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  hasAcceptedWorker
                      ? 'انضم عامل إلى طلبك'
                      : isHotOrder
                      ? 'طلبك المستعجل قيد المتابعة'
                      : 'جارٍ البحث عن عامل مناسب',
                  color: SharedPlatformColors.primary,
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 5),
                AppText.bodySmall(
                  hasAcceptedWorker
                      ? 'نعمل على تأكيد بقية الفريق. سنخبرك عند حدوث أي تغيير.'
                      : 'سنرسل إليك إشعاراً فور توفر عامل وتأكيد طلبك.',
                  color: SharedPlatformColors.muted,
                ),
              ],
            ),
          ),
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
