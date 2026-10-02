import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/extentions.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../helpers/cleaning_event_assistance_helper.dart';

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
    return cleaningOrderStatusLabelAr(
      order.status,
      startedTravelAt: order.startedTravelAt,
      arrivedAt: order.arrivedAt,
    );
  }

  String get _bookingLabel {
    final bookingNumber = order.bookingNumber?.trim();
    return bookingNumber == null || bookingNumber.isEmpty
        ? '#${order.id ?? '-'}'
        : '#$bookingNumber';
  }

  String get _serviceTitle {
    return CleaningEventAssistanceHelper.serviceTitle(
      propertyType: order.propertyType,
      customService: order.propertyDetails?.customService,
    );
  }

  bool get _isPrevious {
    final status = (order.status ?? '').toLowerCase();
    return status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled;
  }

  String get _scheduleLabel {
    final rawDate = order.scheduledDate?.trim();
    final rawTime = order.scheduledTime?.trim();
    final values = <String>[
      if (rawDate != null && rawDate.isNotEmpty) _formatDate(rawDate),
      if (rawTime != null && rawTime.isNotEmpty) _formatTime(rawTime),
    ];
    return values.isEmpty ? 'الموعد غير محدد' : values.join(' • ');
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final location = order.locationName?.trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A101828),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
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
                        Text(
                          _serviceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF172033),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bookingLabel,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(label: _statusLabel, previous: _isPrevious),
                ],
              ),
              const SizedBox(height: 14),
              _OrderMetaRow(
                icon: Icons.calendar_today_outlined,
                value: _scheduleLabel,
              ),
              if (location != null && location.isNotEmpty) ...[
                const SizedBox(height: 9),
                _OrderMetaRow(
                  icon: Icons.location_on_outlined,
                  value: location,
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'الإجمالي',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      (order.totalPrice ?? 0).formatMoney(),
                      style: const TextStyle(
                        color: SharedPlatformColors.cleaning,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: SharedPlatformColors.cleaning,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        _isPrevious ? 'عرض الطلب' : 'متابعة الطلب',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (onRescheduleTap != null && !_isPrevious) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRescheduleTap,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: SharedPlatformColors.cleaning,
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'الموعد',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.previous});

  final String label;
  final bool previous;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: previous ? const Color(0xFFF2F4F7) : const Color(0xFFE9F9FA),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: previous ? const Color(0xFFD0D5DD) : const Color(0xFFB6ECEF),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: previous ? const Color(0xFF475467) : const Color(0xFF0B7480),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OrderMetaRow extends StatelessWidget {
  const _OrderMetaRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF667085)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
