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

  String get _currencyLabel =>
      currency.trim().toUpperCase() == 'SYP' ? 'ل.س' : currency;

  String? get _scheduleDateLine {
    if (scheduleDayLabel == null && scheduleDateLabel == null) return null;
    if (scheduleDayLabel != null && scheduleDateLabel != null) {
      return '$scheduleDayLabel، $scheduleDateLabel';
    }
    return scheduleDayLabel ?? scheduleDateLabel;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleDateLine = _scheduleDateLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scheduleEntries.isNotEmpty ||
            scheduleDateLine != null ||
            (scheduleTimeRange?.isNotEmpty ?? false)) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FC),
              border: Border.all(color: const Color(0xFFE5EAF2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'موعد الخدمة',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                if (scheduleEntries.isNotEmpty)
                  ...scheduleEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _ScheduleEntryRowWidget(entry: entry),
                    ),
                  )
                else ...[
                  if (scheduleDateLine != null) Text(scheduleDateLine),
                  if (scheduleTimeRange?.isNotEmpty ?? false)
                    Text(
                      scheduleTimeRange!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: SharedPlatformColors.primary,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          key: const Key('price_total_card'),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SharedPlatformColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'السعر الإجمالي للطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SharedPlatformColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${totalPrice.formatMoney()} $_currencyLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: SharedPlatformColors.primary,
                ),
              ),
              if (isPricingFinal == false) ...[
                const SizedBox(height: 8),
                const Text(
                  'السعر تقديري، ويتم تأكيده عند إسناد العامل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ],
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
