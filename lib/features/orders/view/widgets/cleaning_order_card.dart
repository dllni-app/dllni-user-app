import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';
import '../helpers/cleaning_event_assistance_helper.dart';
import '../screens/multi_day_cleaning_order_details_screen.dart';

class CleaningOrderCard extends StatefulWidget {
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

  @override
  State<CleaningOrderCard> createState() => _CleaningOrderCardState();
}

class _CleaningOrderCardState extends State<CleaningOrderCard> {
  CleaningBookingScheduleModel? _schedule;

  CleaningOrderModel get order => widget.order;

  bool get _isEventAssistance =>
      (order.propertyType ?? '').trim().toLowerCase() == 'event_assistance';

  bool get _isMultiDay => _schedule?.isMultiDay == true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  void didUpdateWidget(covariant CleaningOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.status != widget.order.status) {
      _schedule = null;
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    final orderId = order.id;
    if (!_isEventAssistance || orderId == null) return;
    try {
      final result = await getIt<CleaningSessionRemoteDataSource>()
          .fetchBookingSchedule(orderId);
      if (!mounted) return;
      setState(() => _schedule = result.schedule);
    } catch (_) {
      // Legacy card remains usable while backend rollout is mixed.
    }
  }

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
    final status = (order.status ?? '').toLowerCase();
    if (status == 'partially_completed') return 'مكتمل جزئياً';
    return cleaningOrderStatusLabelAr(
      order.status,
      startedTravelAt: order.startedTravelAt,
      arrivedAt: order.arrivedAt,
    );
  }

  bool get _isTerminalStatus {
    final normalizedStatus = (order.status ?? '').toLowerCase();
    return normalizedStatus != CleaningBookingStatus.pending;
  }

  String get _bookingLabel {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
  }

  String get _serviceTitle {
    return CleaningEventAssistanceHelper.serviceTitle(
      propertyType: order.propertyType,
      customService: order.propertyDetails?.customService,
    );
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

  String _shortDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _sessionTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return time;
    final suffix = hour >= 12 ? 'م' : 'ص';
    var h = hour % 12;
    if (h == 0) h = 12;
    return '$h:${minute.toString().padLeft(2, '0')} $suffix';
  }

  void _handleTap() {
    final schedule = _schedule;
    final orderId = order.id;
    if (schedule?.isMultiDay == true && orderId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MultiDayCleaningOrderDetailsScreen(
            orderId: orderId,
            initialSessionId: schedule!.nextSession?.id,
          ),
        ),
      );
      return;
    }
    widget.onTap?.call();
  }

  Widget _scheduleContent(BuildContext context) {
    final schedule = _schedule;
    if (schedule == null || !schedule.isMultiDay) {
      return Row(
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
          if (!_isTerminalStatus && widget.onRescheduleTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onRescheduleTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.primary.withAlpha(30),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
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
        ],
      );
    }

    final next = schedule.nextSession;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: context.primary.withAlpha(25),
              child: Icon(Icons.event_repeat, color: context.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelLarge(
                    '${schedule.daysCount} أيام · ${_shortDate(schedule.firstDate)} - ${_shortDate(schedule.lastDate)}',
                    fontWeight: FontWeight.w800,
                  ),
                  AppText.labelMedium(
                    '${schedule.completedDaysCount} / ${schedule.daysCount} مكتمل',
                    color: const Color(0xff6B7280),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffECFDF5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'متعدد الأيام',
                style: TextStyle(
                  color: Color(0xff047857),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        if (next != null) ...[
          const SizedBox(height: 8),
          AppText.labelMedium(
            'الجلسة القادمة: ${_shortDate(next.date)}، ${_sessionTime(next.time)}',
            color: const Color(0xff1E2A78),
            fontWeight: FontWeight.w700,
          ),
        ],
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: schedule.daysCount <= 0
              ? 0
              : (schedule.completedDaysCount / schedule.daysCount).clamp(0, 1),
          minHeight: 4,
          borderRadius: BorderRadius.circular(10),
        ),
        if ((order.status ?? '').toLowerCase() == CleaningBookingStatus.pending &&
            widget.onRescheduleTap != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: widget.onRescheduleTap,
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('تعديل أيام المناسبة'),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _handleTap,
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
                  order.totalPrice.formatMoney(),
                  color: const Color(0xff1E2A78),
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xffE5E7EB), height: 1),
            const SizedBox(height: 10),
            _scheduleContent(context),
            if (!_isTerminalStatus) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffEF4444).withAlpha(25),
                  border: Border.all(color: const Color(0xffEF4444), width: 1),
                ),
                width: context.width,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: InkWell(
                  onTap: widget.onCancelTap ?? widget.onReportIssueTap,
                  borderRadius: BorderRadius.circular(8),
                  child: AppText.labelLarge(
                    _isMultiDay ? 'إلغاء الأيام المتبقية' : 'إلغاء الطلب',
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
