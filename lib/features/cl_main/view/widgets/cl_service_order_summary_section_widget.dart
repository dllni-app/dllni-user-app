import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';

class ClServiceOrderSummarySectionWidget extends StatelessWidget {
  const ClServiceOrderSummarySectionWidget({
    required this.basePrice,
    required this.travelFee,
    required this.addonsTotal,
    required this.totalPrice,
    this.distanceKm,
    this.adminMargin,
    this.isPricingFinal,
    required this.currency,
    super.key,
  });

  final double basePrice;
  final double travelFee;
  final double addonsTotal;
  final double totalPrice;
  final double? distanceKm;
  final double? adminMargin;
  final bool? isPricingFinal;
  final String currency;



  String _formatDistance(double distance) {
    final fixed = distance.toStringAsFixed(3);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final showProvisionalWarning = isPricingFinal == false;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyLarge(
            'ملخص الطلب',
            color: const Color(0xFF1E2A78),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 14),
          _SummaryRowWidget(
            label: 'قيمة الخدمة',
            value: basePrice.formatMoney(),
          ),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: 'رسوم التنقل',
            value: travelFee.formatMoney(),
          ),
          if (distanceKm != null) ...[
            const SizedBox(height: 8),
            _SummaryRowWidget(
              label: 'المسافة',
              value: '${_formatDistance(distanceKm!)} كم',
            ),
          ],
          if (adminMargin != null) ...[
            const SizedBox(height: 8),
            _SummaryRowWidget(
              label: 'هامش الإدارة',
              value: adminMargin.formatMoney(),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: 'الإجمالي',
            value: totalPrice.formatMoney(),
            isTotal: true,
          ),
          if (showProvisionalWarning) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3D6A1)),
              ),
              child: AppText.bodySmall(
                'السعر المعروض تقديري وغير نهائي، وسيتم تأكيد السعر النهائي بعد قبول مقدم الخدمة للطلب.',
                color: const Color(0xFF8A5A12),
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRowWidget extends StatelessWidget {
  const _SummaryRowWidget({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF4B5563);
    return Row(
      children: [
        AppText.bodyMedium(
          label,
          color: color,
          fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          textAlign: TextAlign.right,
        ),
        const Spacer(),
        AppText.bodyMedium(
          value,
          color: color,
          fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
