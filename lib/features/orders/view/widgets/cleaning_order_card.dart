import 'package:flutter/material.dart';

import '../../../../core/extensions/extentions.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../helpers/cleaning_event_assistance_helper.dart';

/// V6 customer order tile. Existing order model and command callbacks are
/// authoritative; only their presentation belongs here.
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

  bool get _ended =>
      order.status == CleaningBookingStatus.completed ||
      order.status == CleaningBookingStatus.cancelled;

  bool get _cancelled => order.status == CleaningBookingStatus.cancelled;

  String get _status {
    if (order.isSearchingForWorkers) {
      return (order.workerAcceptance?.accepted ?? 0) > 0
          ? 'انضم عامل إلى طلبك'
          : order.isHotOrder
          ? 'طلبك المستعجل قيد المتابعة'
          : (order.numberOfWorkers ?? 1) > 1
          ? 'جارٍ تجهيز فريق التنظيف'
          : 'جارٍ البحث عن عامل مناسب';
    }
    return cleaningOrderStatusLabelAr(
      order.status,
      startedTravelAt: order.startedTravelAt,
      arrivedAt: order.arrivedAt,
    );
  }

  String get _service {
    if (order.openTime != null) return 'خدمة بالساعة';
    return CleaningEventAssistanceHelper.serviceTitle(
      propertyType: order.propertyType,
      customService: order.propertyDetails?.customService,
    );
  }

  IconData get _serviceIcon {
    if (order.openTime != null) {
      return Icons.access_time_rounded;
    }
    if (order.propertyType == 'event_assistance') {
      return Icons.celebration_outlined;
    }
    return Icons.cleaning_services_outlined;
  }

  String get _reference {
    final code = order.bookingNumber?.trim();
    return 'رقم الطلب #${code == null || code.isEmpty ? (order.id?.toString() ?? '-') : code}';
  }

  String get _date {
    final d = order.scheduledDate?.trim();
    final t = order.scheduledTime?.trim();
    if ((d == null || d.isEmpty) && (t == null || t.isEmpty)) {
      return 'الموعد غير محدد';
    }
    final parsedDate = d == null ? null : DateTime.tryParse(d);
    return [
      if (d != null && d.isNotEmpty)
        parsedDate == null ? d : CleaningDateTimeUiFormat.date(parsedDate),
      if (t != null && t.isNotEmpty) CleaningDateTimeUiFormat.time(t),
    ].join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final badgeInk = _cancelled
        ? SharedPlatformColors.danger
        : _ended
        ? SharedPlatformColors.muted
        : SharedPlatformColors.cleaningInk;
    final badgeSurface = _cancelled
        ? const Color(0xFFFFF0F1)
        : _ended
        ? SharedPlatformColors.background
        : SharedPlatformColors.cleaningSoft;
    return Semantics(
      container: true,
      label: '$_service، $_reference، $_status',
      child: Material(
        color: SharedPlatformColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: SharedPlatformColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SharedPlatformColors.cleaningSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _serviceIcon,
                        color: SharedPlatformColors.cleaningInk,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _service,
                            style: AlnadhaTokens.sectionTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _reference,
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            style: AlnadhaTokens.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                    decoration: BoxDecoration(
                      color: badgeSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _status,
                      style: AlnadhaTokens.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: badgeInk,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _OrderMeta(icon: Icons.event_outlined, label: _date),
                if (order.locationName?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _OrderMeta(
                    icon: Icons.location_on_outlined,
                    label: order.locationName!.trim(),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: SharedPlatformColors.border),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التكلفة', style: AlnadhaTokens.caption),
                          const SizedBox(height: 2),
                          Text(
                            order.totalPrice == null
                                ? 'قيد التحديد'
                                : order.totalPrice!.formatMoney(),
                            style: AlnadhaTokens.sectionTitle.copyWith(
                              color: SharedPlatformColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                        ),
                        label: Text(_ended ? 'التفاصيل' : 'متابعة الطلب'),
                        style: TextButton.styleFrom(
                          foregroundColor: SharedPlatformColors.primary,
                          minimumSize: const Size(48, 48),
                          textStyle: AlnadhaTokens.button,
                        ),
                      ),
                  ],
                ),
                if (onRescheduleTap != null && !_ended) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRescheduleTap,
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('تعديل الموعد'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SharedPlatformColors.primary,
                      side: const BorderSide(
                        color: SharedPlatformColors.border,
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: AlnadhaTokens.button,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  const _OrderMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: SharedPlatformColors.cleaningInk),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AlnadhaTokens.body.copyWith(
            fontSize: 13,
            color: SharedPlatformColors.muted,
          ),
        ),
      ),
    ],
  );
}
