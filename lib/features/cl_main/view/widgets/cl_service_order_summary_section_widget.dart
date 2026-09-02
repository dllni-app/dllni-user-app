import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';

class ClServiceScheduleEntry {
  const ClServiceScheduleEntry({
    required this.dayDate,
    required this.time,
  });

  final String dayDate;
  final String time;
}

class ClServiceOrderSummarySectionWidget extends StatelessWidget {
  const ClServiceOrderSummarySectionWidget({
    required this.basePrice,
    required this.travelFee,
    required this.addonsTotal,
    required this.totalPrice,
    this.discountAmount,
    this.totalAfterDiscount,
    this.distanceKm,
    this.adminMargin,
    this.isPricingFinal,
    required this.currency,
    this.scheduleDayLabel,
    this.scheduleDateLabel,
    this.scheduleTimeRange,
    this.scheduleEntries = const <ClServiceScheduleEntry>[],
    super.key,
  });

  final double basePrice;
  final double travelFee;
  final double addonsTotal;
  final double totalPrice;
  final double? discountAmount;
  final double? totalAfterDiscount;
  final double? distanceKm;
  final double? adminMargin;
  final bool? isPricingFinal;
  final String currency;
  final String? scheduleDayLabel;
  final String? scheduleDateLabel;
  final String? scheduleTimeRange;
  final List<ClServiceScheduleEntry> scheduleEntries;

  String _formatDistance(double distance) {
    final fixed = distance.toStringAsFixed(3);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String? get _scheduleDateLine {
    if (scheduleDayLabel == null && scheduleDateLabel == null) return null;
    if (scheduleDayLabel != null && scheduleDateLabel != null) {
      return '$scheduleDayLabel، $scheduleDateLabel';
    }
    return scheduleDayLabel ?? scheduleDateLabel;
  }

  @override
  Widget build(BuildContext context) {
    final showProvisionalWarning = isPricingFinal == false;
    final scheduleDateLine = _scheduleDateLine;
    final hasScheduleEntries = scheduleEntries.isNotEmpty;
    final displayedServicePrice = basePrice + (adminMargin ?? 0);
    final hasDiscount = discountAmount != null && discountAmount! > 0;
    // Coupon amounts are calculated on the coupon-eligible subtotal only.
    // Keep non-coupon charges (for example admin margin/travel) in the final
    // customer total by subtracting the authoritative discount from the
    // estimate total instead of displaying coupon.amounts.total directly.
    final displayedTotal = hasDiscount
        ? (totalPrice - discountAmount!).clamp(0, double.infinity).toDouble()
        : totalPrice;
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
          if (hasScheduleEntries) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppText.bodyMedium(
                'مواعيد الخدمة',
                color: const Color(0xFF1E2A78),
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(scheduleEntries.length, (index) {
              final entry = scheduleEntries[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == scheduleEntries.length - 1 ? 0 : 9,
                ),
                child: _ScheduleEntryRowWidget(entry: entry),
              );
            }),
            const SizedBox(height: 10),
          ] else ...[
            if (scheduleDateLine != null) ...[
              _SummaryRowWidget(label: 'موعد الخدمة', value: scheduleDateLine),
              const SizedBox(height: 8),
            ],
            if (scheduleTimeRange != null && scheduleTimeRange!.isNotEmpty) ...[
              _SummaryRowWidget(label: 'الوقت', value: scheduleTimeRange!),
              const SizedBox(height: 8),
            ],
          ],
          if (hasScheduleEntries ||
              scheduleDateLine != null ||
              (scheduleTimeRange != null && scheduleTimeRange!.isNotEmpty)) ...[
            const Divider(color: Color(0xFFE5E7EB), thickness: 1),
            const SizedBox(height: 8),
          ],
          _SummaryRowWidget(
            label: 'قيمة الخدمة',
            value: displayedServicePrice.formatMoney(),
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
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            _SummaryRowWidget(
              label: 'الخصم',
              value: '- ${discountAmount!.formatMoney()}',
              valueColor: const Color(0xFF047857),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: hasDiscount ? 'الإجمالي بعد الخصم' : 'الإجمالي',
            value: displayedTotal.formatMoney(),
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
                'السعر المعروض تقديري وغير نهائي، وسيتم اضافة رسوم التنقل بعد قبول مقدم الخدمة للطلب.',
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

class _ScheduleEntryRowWidget extends StatelessWidget {
  const _ScheduleEntryRowWidget({required this.entry});

  final ClServiceScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: AppText.bodyMedium(
            entry.dayDate,
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppText.bodyMedium(
            entry.time,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _SummaryRowWidget extends StatelessWidget {
  const _SummaryRowWidget({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF4B5563);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: AppText.bodyMedium(
            label,
            color: color,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: AppText.bodyMedium(
            value,
            color: valueColor ?? color,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
