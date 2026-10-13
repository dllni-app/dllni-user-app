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
    CleaningBookingStatus.timeExtensionRequested => 2,
    CleaningBookingStatus.awaitingStartVerification ||
    CleaningBookingStatus.awaitingWorkerStartConfirmation => 2,
    CleaningBookingStatus.workerAssigned => 1,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final status = (order.status ?? '').toLowerCase().trim();
    if (status == CleaningBookingStatus.underDispute) {
      // A dispute can start in different lifecycle stages. Never invent
      // completed worker, travel, or cleaning milestones in this state.
      return const V7OrderPanel(
        key: Key('cleaning_order_dispute_timeline'),
        title: 'مراجعة المشكلة',
        subtitle: 'حالة الطلب قيد المراجعة',
        leading: Icon(Icons.report_problem_outlined, color: Color(0xFFAB691C)),
        child: Text(
          'تم تسجيل المشكلة المرتبطة بطلبك. ستظهر التحديثات بعد مراجعتها، ولا يُعد العمل مكتملاً حتى تتغير حالة الطلب.',
          textAlign: TextAlign.start,
        ),
      );
    }
    final cancelled = status == CleaningBookingStatus.cancelled;
    final int stage = _stage;
    final travelStarted = order.startedTravelAt?.trim().isNotEmpty == true;
    final arrived = order.arrivedAt?.trim().isNotEmpty == true;
    final acceptedCount =
        order.workerAcceptance?.accepted ??
        order.acceptedWorkerAssignments.length;
    final workerStep = switch (status) {
      CleaningBookingStatus.pending when acceptedCount > 0 => const _OrderStep(
        'بانتظار اكتمال الفريق',
        'قبل بعض العمال طلبك، وننتظر اكتمال العدد المطلوب',
      ),
      CleaningBookingStatus.workerAssigned when arrived => const _OrderStep(
        'وصل مقدم الخدمة',
        'تم تسجيل وصول مقدم الخدمة إلى الموقع',
      ),
      CleaningBookingStatus.workerAssigned when travelStarted =>
        const _OrderStep(
          'مقدم الخدمة في الطريق',
          'بدأ مقدم الخدمة التحرك نحو موقع العمل',
        ),
      CleaningBookingStatus.awaitingStartVerification ||
      CleaningBookingStatus.awaitingWorkerStartConfirmation => const _OrderStep(
        'وصل مقدم الخدمة',
        'أصبح العامل جاهزاً للتحقق من بدء الخدمة',
      ),
      _ => const _OrderStep('تأكيد مقدم الخدمة', 'سنخبرك عند قبول الطلب'),
    };
    final workStep = switch (status) {
      CleaningBookingStatus.awaitingStartVerification => const _OrderStep(
        'التحقق من رمز الأمان',
        'أدخل الرمز المكوّن من 4 أرقام الذي يقدّمه العامل',
      ),
      CleaningBookingStatus.awaitingWorkerStartConfirmation => const _OrderStep(
        'بانتظار بدء العمل',
        'تم التحقق من الرمز، وننتظر تأكيد العامل',
      ),
      CleaningBookingStatus.inProgress => const _OrderStep(
        'الخدمة قيد التنفيذ',
        'بدأ العمل بعد اكتمال خطوات التحقق',
      ),
      CleaningBookingStatus.timeExtensionRequested => const _OrderStep(
        'طلب التمديد قيد المعالجة',
        'ننتظر رد العامل على طلب الوقت الإضافي',
      ),
      _ => const _OrderStep('بدء تنفيذ الخدمة', 'يبدأ العمل بعد التحقق'),
    };
    final steps = cancelled
        ? const <_OrderStep>[
            _OrderStep('تم استلام الطلب', 'تم تسجيل طلب الخدمة'),
            _OrderStep('تم إلغاء الطلب', 'لن تُنفّذ هذه الخدمة'),
          ]
        : <_OrderStep>[
            const _OrderStep('تم استلام الطلب', 'سُجل طلبك في النظام'),
            workerStep,
            workStep,
            const _OrderStep('مراجعة الإنجاز', 'تأكيد اكتمال المهام'),
            const _OrderStep('اكتمال الطلب', 'انتهاء الخدمة'),
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
                  current && !cancelled
                      ? 'المرحلة الحالية • $description'
                      : description,
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
