import 'package:common_package/common_package.dart';
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

  String _formatMoney(double amount) {
    final rounded = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final reverseIndex = rounded.length - i;
      buffer.write(rounded[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return '$currency ${buffer.toString()}';
  }

  String _formatDistance(double distance) {
    final fixed = distance.toStringAsFixed(3);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final showProvisionalWarning = isPricingFinal == false;
    final showAddons = addonsTotal > 0;
    final hasOperationalPricing = adminMargin != null || distanceKm != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyLarge(
                      'ملخص الطلب',
                      color: const Color(0xFF1E2A78),
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 3),
                    AppText.bodySmall(
                      'تتحدث القيم تلقائياً عند اختيار عامل مفضل أو تغيير بيانات الطلب.',
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PricingStatusChip(isPricingFinal: isPricingFinal),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRowWidget(
            label: 'قيمة الخدمة',
            value: _formatMoney(basePrice),
          ),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: 'رسوم التنقل',
            value: _formatMoney(travelFee),
          ),
          if (showAddons) ...[
            const SizedBox(height: 8),
            _SummaryRowWidget(
              label: 'خدمات إضافية',
              value: _formatMoney(addonsTotal),
            ),
          ],
          if (hasOperationalPricing) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  if (distanceKm != null)
                    _SummaryRowWidget(
                      label: 'المسافة',
                      value: '${_formatDistance(distanceKm!)} كم',
                      dense: true,
                    ),
                  if (distanceKm != null && adminMargin != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ),
                  if (adminMargin != null)
                    _SummaryRowWidget(
                      label: 'هامش الإدارة',
                      value: _formatMoney(adminMargin!),
                      dense: true,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: 'الإجمالي',
            value: _formatMoney(totalPrice),
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
                'السعر تقديري حالياً، وسيصبح نهائياً بعد اختيار أو قبول مقدم الخدمة حسب توفر بيانات المسافة والهامش.',
                color: const Color(0xFF8A5A12),
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PricingStatusChip extends StatelessWidget {
  const _PricingStatusChip({required this.isPricingFinal});

  final bool? isPricingFinal;

  @override
  Widget build(BuildContext context) {
    final isFinal = isPricingFinal == true;
    final label = isFinal ? 'نهائي' : 'تقديري';
    final background = isFinal ? const Color(0xFFEAF7EF) : const Color(0xFFFFF7E8);
    final foreground = isFinal ? const Color(0xFF047857) : const Color(0xFF8A5A12);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText.bodySmall(
        label,
        color: foreground,
        fontWeight: FontWeight.w800,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SummaryRowWidget extends StatelessWidget {
  const _SummaryRowWidget({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.dense = false,
  });

  final String label;
  final String value;
  final bool isTotal;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF4B5563);
    final valueColor = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF111827);
    final fontSize = isTotal ? 16.0 : (dense ? 13.0 : 14.0);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
