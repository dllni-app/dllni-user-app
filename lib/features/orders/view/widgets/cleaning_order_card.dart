import 'package:flutter/material.dart';

import '../../../../core/extensions/extentions.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../helpers/cleaning_event_assistance_helper.dart';

/// Redesigned Pen V7 order item; only display logic lives here.
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
  final VoidCallback? onTap, onRescheduleTap, onReportIssueTap, onCancelTap;

  bool get _ended =>
      order.status == CleaningBookingStatus.completed ||
      order.status == CleaningBookingStatus.cancelled;

  String get _status {
    if (order.isSearchingForWorkers) {
      return (order.workerAcceptance?.accepted ?? 0) > 0
          ? 'انضم عامل إلى طلبك'
          : order.isHotOrder
          ? 'طلبك المستعجل قيد المتابعة'
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

  String get _reference {
    final code = order.bookingNumber?.trim();
    return code == null || code.isEmpty
        ? 'رقم الطلب #' + (order.id?.toString() ?? '-')
        : 'رقم الطلب #' + code;
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6E9EE)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  V7ArtTile(
                    asset: V7Artwork.categoryCleaning,
                    size: 54,
                    background: SharedPlatformColors.cleaningSoft,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _service,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: SharedPlatformColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _reference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SharedPlatformColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _ended
                            ? const Color(0xFFF3F4F7)
                            : SharedPlatformColors.cleaningSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _status,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _ended
                              ? SharedPlatformColors.muted
                              : const Color(0xFF047B87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Meta(icon: Icons.calendar_today_outlined, label: _date),
              if (order.locationName?.isNotEmpty == true) ...[
                const SizedBox(height: 7),
                _Meta(
                  icon: Icons.location_on_outlined,
                  label: order.locationName!,
                ),
              ],
              const Divider(height: 22, color: Color(0xFFE9ECF1)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.totalPrice == null
                          ? 'التكلفة قيد التحديد'
                          : order.totalPrice!.formatMoney(),
                      style: const TextStyle(
                        color: SharedPlatformColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _ended ? 'عرض التفاصيل' : 'متابعة الطلب',
                          style: const TextStyle(
                            color: Color(0xFF0A7F8C),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 12,
                          color: Color(0xFF0A7F8C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onRescheduleTap != null && !_ended) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onRescheduleTap,
                  icon: const Icon(Icons.event_available_outlined, size: 16),
                  label: const Text('تعديل الموعد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SharedPlatformColors.primary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: const Color(0xFF08818B)),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SharedPlatformColors.muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}
