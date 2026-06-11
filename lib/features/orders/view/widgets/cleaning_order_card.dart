import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';

class CleaningOrderCard extends StatelessWidget {
  const CleaningOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onRescheduleTap,
    this.onReportIssueTap,
    this.onCancelTap,
  });

  final CleaningOrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onRescheduleTap;
  final VoidCallback? onReportIssueTap;
  final VoidCallback? onCancelTap;

  String get _statusLabel {
    if (order.isSearchingForWorkers) {
      final accepted = order.workerAcceptance?.accepted ?? 0;
      final required =
          order.workerAcceptance?.required ?? order.numberOfWorkers ?? 0;
      if (required > 0) {
        return 'جاري البحث عن عمال ($accepted/$required)';
      }
      return 'جاري البحث عن عمال';
    }
    return cleaningOrderStatusLabelAr(order.status);
  }

  bool get _isTerminalStatus {
    final normalizedStatus = (order.status ?? '').toLowerCase();
    return normalizedStatus == CleaningBookingStatus.completed ||
        normalizedStatus == CleaningBookingStatus.cancelled;
  }

  String get _bookingLabel {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
  }

  String get _priceLabel {
    final totalPrice = order.totalPrice ?? 0;
    return '${totalPrice.formatWithComma()} ل.س';
  }

  String get _serviceTitle {
    switch ((order.propertyType ?? '').toLowerCase()) {
      case 'studio':
        return 'خدمة تنظيف ستوديو';
      case 'apartment':
        return 'خدمة تنظيف شقة';
      case 'house':
        return 'خدمة تنظيف منزل';
      case 'villa':
        return 'خدمة تنظيف فيلا';
      default:
        return 'خدمة تنظيف منزل';
    }
  }

  String get _timeLabel {
    final value = order.scheduledTime;
    if (value == null || value.isEmpty) return '-';
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String get _dateLabel {
    final rawDate = order.scheduledDate;
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return rawDate;
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  String get _dayLabel {
    final rawDate = order.scheduledDate;
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    const arabicDays = <String>[
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return arabicDays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText.bodySmall(
                    _bookingLabel,
                    color: const Color(0xff9CA3AF),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F5F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText.labelLarge(
                    _statusLabel,
                    color: const Color(0xff0CBBC7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppText.bodyLarge(
                    _serviceTitle,
                    color: const Color(0xff111827),
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                AppText.bodySmall(
                  _priceLabel,
                  color: const Color(0xff1E2A78),
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: const Color(0xffE5E7EB), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: context.primary.withAlpha(25),
                  child: Icon(
                    Icons.calendar_today,
                    color: context.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.labelMedium(
                        _dayLabel,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.start,
                      ),
                      AppText.labelMedium(
                        '$_dateLabel - $_timeLabel',
                        color: const Color(0xff6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRescheduleTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.primary.withAlpha(30),
                    ),
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: AppText.labelLarge(
                      'تغيير موعد الخدمة',
                      fontWeight: FontWeight.bold,
                      color: context.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (!_isTerminalStatus) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffEF4444).withAlpha(25),
                  border: Border.all(color: const Color(0xffEF4444), width: 1),
                ),
                width: context.width,
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: InkWell(
                  onTap: onCancelTap ?? onReportIssueTap,
                  borderRadius: BorderRadius.circular(8),
                  child: AppText.labelLarge(
                    'إلغاء الطلب',
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    color: const Color(0xffDC2626),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
