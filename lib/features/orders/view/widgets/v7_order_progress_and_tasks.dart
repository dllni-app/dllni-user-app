import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import 'v7_order_detail_components.dart';

/// A Pen V7 progress trail based strictly on the booking's persisted status.
/// No invented timestamps, acceptance or location milestones.
class V7OrderLifecyclePanel extends StatelessWidget {
  const V7OrderLifecyclePanel({super.key, required this.order});
  final CleaningOrderDetailModel order;

  int get _stage => switch ((order.status ?? '').toLowerCase().trim()) {
    CleaningBookingStatus.completed => 4,
    CleaningBookingStatus.awaitingCustomerCompletion => 3,
    CleaningBookingStatus.inProgress ||
    CleaningBookingStatus.timeExtensionRequested ||
    CleaningBookingStatus.underDispute => 2,
    CleaningBookingStatus.workerAssigned ||
    CleaningBookingStatus.awaitingStartVerification ||
    CleaningBookingStatus.awaitingWorkerStartConfirmation => 1,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final cancelled =
        (order.status ?? '').toLowerCase().trim() ==
        CleaningBookingStatus.cancelled;
    final int stage = _stage;
    final steps = cancelled
        ? const <_OrderStep>[
            _OrderStep('تم استلام الطلب', 'تم تسجيل طلب الخدمة'),
            _OrderStep('تم إلغاء الطلب', 'لن تُنفّذ هذه الخدمة'),
          ]
        : const <_OrderStep>[
            _OrderStep('تم استلام الطلب', 'سُجل طلبك في النظام'),
            _OrderStep('تأكيد مقدم الخدمة', 'سنخبرك عند قبول الطلب'),
            _OrderStep('بدء تنفيذ الخدمة', 'يبدأ العمل بعد التحقق'),
            _OrderStep('مراجعة الإنجاز', 'تأكيد اكتمال المهام'),
            _OrderStep('اكتمال الطلب', 'انتهاء الخدمة'),
          ];
    return V7OrderPanel(
      title: 'سجل الطلب',
      subtitle: 'الحالة الحالية والخطوات التالية',
      leading: const Icon(
        Icons.route_outlined,
        color: SharedPlatformColors.cleaning,
        size: 23,
      ),
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++)
            _TimelineRow(
              title: steps[index].title,
              description: steps[index].description,
              completed: cancelled ? index == 0 : (stage == 4 || index < stage),
              current: cancelled ? index == 1 : (stage != 4 && index == stage),
              last: index == steps.length - 1,
              cancelled: cancelled && index == 1,
            ),
        ],
      ),
    );
  }
}

class _OrderStep {
  const _OrderStep(this.title, this.description);
  final String title, description;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.description,
    required this.completed,
    required this.current,
    required this.last,
    this.cancelled = false,
  });
  final String title, description;
  final bool completed, current, last, cancelled;

  @override
  Widget build(BuildContext context) {
    final accent = cancelled
        ? const Color(0xFFB73E49)
        : const Color(0xFF07808B);
    final ink = completed || current
        ? SharedPlatformColors.ink
        : SharedPlatformColors.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed || current
                      ? accent
                      : const Color(0xFFE8ECF1),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : current
                    ? Icon(
                        cancelled ? Icons.close_rounded : Icons.circle,
                        color: Colors.white,
                        size: cancelled ? 15 : 9,
                      )
                    : const Icon(Icons.circle, color: Colors.white, size: 8),
              ),
              if (!last)
                Container(
                  height: 30,
                  width: 2,
                  color: completed
                      ? const Color(0xFF07808B)
                      : const Color(0xFFE1E6ED),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: completed || current
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  current && !cancelled ? 'المرحلة الحالية' : description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: SharedPlatformColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Required tasks come from the API line-items, falling back only to the
/// room-count fields that actually exist on the same order.
class V7OrderServicesPanel extends StatelessWidget {
  const V7OrderServicesPanel({super.key, required this.order});
  final CleaningOrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    final services = order.services ?? const <CleaningOrderLineItemModel>[];
    final addons = order.addons ?? const <CleaningOrderLineItemModel>[];
    final details = order.propertyDetails;
    final roomCounts = <String, int?>{
      'غرف النوم': details?.bedrooms,
      'الحمامات': details?.bathrooms,
      'المطابخ': details?.kitchens ?? order.numberOfKitchens,
    };
    final hasCounts = roomCounts.values.any((v) => v != null && v > 0);
    if (services.isEmpty && addons.isEmpty && !hasCounts) {
      return const SizedBox.shrink();
    }
    return V7OrderPanel(
      title: 'المهام المطلوبة',
      leading: const Icon(
        Icons.checklist_rounded,
        color: SharedPlatformColors.cleaning,
        size: 24,
      ),
      subtitle: 'ما تم إدراجه ضمن طلب الخدمة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (services.isNotEmpty)
            for (final item in services)
              _ServiceRow(
                label: item.name?.trim().isNotEmpty == true
                    ? item.name!.trim()
                    : 'خدمة تنظيف',
                count: item.quantity,
              )
          else if (hasCounts)
            for (final entry in roomCounts.entries)
              if ((entry.value ?? 0) > 0)
                _ServiceRow(label: entry.key, count: entry.value),
          if (addons.isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFE9EDF1)),
            const Text(
              'إضافات الطلب',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: SharedPlatformColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in addons)
              _ServiceRow(
                label: item.name ?? 'خدمة إضافية',
                count: item.quantity,
              ),
          ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.label, this.count});
  final String label;
  final int? count;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 19,
          color: Color(0xFF087F89),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (count != null && count! > 1)
          Text(
            '×$count',
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 12,
            ),
          ),
      ],
    ),
  );
}
