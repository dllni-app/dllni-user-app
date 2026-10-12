import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';
import '../../data/models/estimate_price_response_model.dart';

class ClServiceScheduleEntry {
  const ClServiceScheduleEntry({required this.dayDate, required this.time});

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
    this.minimumOrderPrice,
    this.minimumOrderApplied = false,
    this.priceSummary,
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
  final double? minimumOrderPrice;
  final bool minimumOrderApplied;
  final EstimatePriceSummaryModel? priceSummary;
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
    final showMinimumOrderWarning =
        minimumOrderApplied &&
        minimumOrderPrice != null &&
        minimumOrderPrice! > 0;
    final scheduleDateLine = _scheduleDateLine;
    final hasScheduleEntries = scheduleEntries.isNotEmpty;
    // Split the server total for presentation only. Minimum-order adjustment
    // and management margin remain in the service row; neither is added again.
    final displayedAddons = addonsTotal
        .clamp(0, (totalPrice - travelFee).clamp(0, double.infinity))
        .toDouble();
    final displayedServicePrice = (totalPrice - travelFee - displayedAddons)
        .clamp(0, double.infinity)
        .toDouble();
    final hasDiscount = discountAmount != null && discountAmount! > 0;
    // The coupon preview prices one visit without all selected extras.
    // Submission re-quotes the full booking, so this total stays unchanged.
    final displayedTotal = totalPrice;
    final summary = priceSummary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SharedPlatformColors.border),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyLarge(
            'ملخص السعر',
            color: SharedPlatformColors.primary,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 14),
          if (hasScheduleEntries) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppText.bodyMedium(
                'مواعيد الخدمة',
                color: SharedPlatformColors.primary,
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
            label: 'الخدمة والعمال',
            value: (summary?.serviceCharge ?? displayedServicePrice)
                .formatMoney(),
          ),
          const SizedBox(height: 8),
          if (summary != null && summary.materials > 0) ...[
            _SummaryRowWidget(
              label: 'مواد التنظيف',
              value: summary.materials.formatMoney(),
            ),
            const SizedBox(height: 8),
          ],
          if (summary != null && summary.specialServices > 0) ...[
            _SummaryRowWidget(
              label: 'الخدمات المتخصصة',
              value: summary.specialServices.formatMoney(),
            ),
            const SizedBox(height: 8),
          ],
          if (summary == null && displayedAddons > 0) ...[
            _SummaryRowWidget(
              label: 'الخدمات والمواد الإضافية',
              value: displayedAddons.formatMoney(),
            ),
            const SizedBox(height: 8),
          ],
          _SummaryRowWidget(
            label: 'رسوم التنقل',
            value: (summary?.transport ?? travelFee).formatMoney(),
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
              label: 'الخصم المتوقع',
              value: '- ${discountAmount!.formatMoney()}',
              valueColor: const Color(0xFF047857),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 8),
          _SummaryRowWidget(
            label: summary?.quoteKind == 'preliminary'
                ? 'الإجمالي المبدئي (الحد الأدنى)'
                : isPricingFinal == false
                ? 'الإجمالي التقديري'
                : 'الإجمالي',
            value: displayedTotal.formatMoney(),
            isTotal: true,
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 6),
            const Text(
              'الخصم المعروض مبدئي. سيؤكد النظام المبلغ النهائي عند إرسال الطلب.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
          if (showMinimumOrderWarning) ...[
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
                'أقل قيمة لطلب التنظيف هي ${minimumOrderPrice!.formatMoney()}، وتم اعتمادها لأن قيمة الطلب أقل من الحد الأدنى.',
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
          child: AppText.bodyMedium(
            entry.dayDate,
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText.bodyMedium(
            entry.time,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.end,
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
    final color = isTotal
        ? SharedPlatformColors.primary
        : SharedPlatformColors.ink;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText.bodyMedium(
            label,
            color: color,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
