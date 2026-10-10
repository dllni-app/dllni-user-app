import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

import '../../data/models/cleaning_booking_status.dart';

enum CleaningLifecycleActionKind {
  refreshSearch,
  trackTeam,
  verifyStart,
  waitingForWorkerStart,
  followProgress,
  completionDecision,
  waitingExtension,
  rateService,
  none,
}

class CleaningLifecycleActionSpec {
  const CleaningLifecycleActionSpec({
    required this.kind,
    required this.label,
    required this.icon,
  });

  final CleaningLifecycleActionKind kind;
  final String label;
  final IconData icon;
}

CleaningLifecycleActionSpec cleaningLifecyclePrimaryAction(String? status) {
  final normalized = (status ?? '').trim().toLowerCase();
  return switch (normalized) {
    CleaningBookingStatus.pending => const CleaningLifecycleActionSpec(
      kind: CleaningLifecycleActionKind.refreshSearch,
      label: 'تحديث حالة البحث',
      icon: Icons.refresh_rounded,
    ),
    CleaningBookingStatus.workerAssigned => const CleaningLifecycleActionSpec(
      kind: CleaningLifecycleActionKind.trackTeam,
      label: 'متابعة وصول الفريق',
      icon: Icons.route_outlined,
    ),
    CleaningBookingStatus.awaitingStartVerification =>
      const CleaningLifecycleActionSpec(
        kind: CleaningLifecycleActionKind.verifyStart,
        label: 'إدخال رمز بدء الخدمة',
        icon: Icons.verified_user_outlined,
      ),
    CleaningBookingStatus.awaitingWorkerStartConfirmation =>
      const CleaningLifecycleActionSpec(
        kind: CleaningLifecycleActionKind.waitingForWorkerStart,
        label: 'تحديث حالة بدء العمل',
        icon: Icons.hourglass_top_rounded,
      ),
    CleaningBookingStatus.inProgress => const CleaningLifecycleActionSpec(
      kind: CleaningLifecycleActionKind.followProgress,
      label: 'متابعة الخدمة',
      icon: Icons.cleaning_services_outlined,
    ),
    CleaningBookingStatus.awaitingCustomerCompletion =>
      const CleaningLifecycleActionSpec(
        kind: CleaningLifecycleActionKind.completionDecision,
        label: 'مراجعة إكمال الخدمة',
        icon: Icons.fact_check_outlined,
      ),
    CleaningBookingStatus.timeExtensionRequested =>
      const CleaningLifecycleActionSpec(
        kind: CleaningLifecycleActionKind.waitingExtension,
        label: 'تحديث طلب التمديد',
        icon: Icons.more_time_rounded,
      ),
    CleaningBookingStatus.completed => const CleaningLifecycleActionSpec(
      kind: CleaningLifecycleActionKind.rateService,
      label: 'تقييم الخدمة',
      icon: Icons.star_outline_rounded,
    ),
    _ => const CleaningLifecycleActionSpec(
      kind: CleaningLifecycleActionKind.none,
      label: '',
      icon: Icons.info_outline,
    ),
  };
}

int cleaningLifecycleStageIndex(String? status) {
  final normalized = (status ?? '').trim().toLowerCase();
  return switch (normalized) {
    CleaningBookingStatus.pending => 0,
    CleaningBookingStatus.workerAssigned => 1,
    CleaningBookingStatus.awaitingStartVerification ||
    CleaningBookingStatus.awaitingWorkerStartConfirmation => 2,
    CleaningBookingStatus.inProgress => 3,
    CleaningBookingStatus.awaitingCustomerCompletion ||
    CleaningBookingStatus.timeExtensionRequested => 4,
    CleaningBookingStatus.completed => 5,
    _ => 0,
  };
}

class CleaningLifecycleTimelineWidget extends StatelessWidget {
  const CleaningLifecycleTimelineWidget({
    super.key,
    required this.status,
    this.startedTravelAt,
    this.arrivedAt,
    this.forceTravelling = false,
    this.acceptedWorkers,
    this.requiredWorkers,
    this.compact = false,
  });

  final String? status;
  final String? startedTravelAt;
  final String? arrivedAt;
  final bool forceTravelling;
  final int? acceptedWorkers;
  final int? requiredWorkers;

  /// Show only the current stage until the customer chooses to expand it.
  final bool compact;

  static const _labels = <String>[
    'البحث عن العمال',
    'تجهيز الفريق والوصول',
    'التحقق وبدء الخدمة',
    'التنظيف جارٍ',
    'مراجعة الإكمال',
    'اكتمل الطلب',
  ];

  @override
  Widget build(BuildContext context) {
    final normalized = (status ?? '').trim().toLowerCase();
    if (normalized == CleaningBookingStatus.cancelled) {
      return _CancelledTimelineCard();
    }

    final activeIndex = cleaningLifecycleStageIndex(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharedPlatformColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مسار الطلب',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: SharedPlatformColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentDescription(normalized),
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          if (compact)
            ExpansionTile(
              key: ValueKey('cleaning_timeline_expand_$normalized'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: false,
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: SharedPlatformColors.cleaningSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: SharedPlatformColors.cleaningInk,
                  size: 17,
                ),
              ),
              title: Text(
                _labels[activeIndex],
                style: const TextStyle(
                  color: SharedPlatformColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'المرحلة ${activeIndex + 1} من ${_labels.length} • عرض جميع المراحل',
                style: const TextStyle(
                  color: SharedPlatformColors.muted,
                  fontSize: 11,
                ),
              ),
              children: [
                const SizedBox(height: 8),
                for (var index = 0; index < _labels.length; index++)
                  _TimelineStep(
                    label: _labels[index],
                    isCompleted: index < activeIndex,
                    isCurrent: index == activeIndex,
                    isLast: index == _labels.length - 1,
                  ),
              ],
            )
          else
            for (var index = 0; index < _labels.length; index++)
              _TimelineStep(
                label: _labels[index],
                isCompleted: index < activeIndex,
                isCurrent: index == activeIndex,
                isLast: index == _labels.length - 1,
              ),
        ],
      ),
    );
  }

  String _currentDescription(String status) {
    if (status == CleaningBookingStatus.pending) {
      final accepted = acceptedWorkers;
      final required = requiredWorkers;
      if (accepted != null && required != null && required > 0) {
        return 'تم قبول $accepted من $required عامل. سنحدّث الطلب عند اكتمال الفريق.';
      }
      return 'نبحث عن الفريق المناسب وفق تفاصيل حجزك.';
    }
    if (status == CleaningBookingStatus.workerAssigned) {
      if (arrivedAt?.trim().isNotEmpty == true) {
        return 'وصل الفريق إلى موقع الخدمة.';
      }
      if (forceTravelling || startedTravelAt?.trim().isNotEmpty == true) {
        return 'الفريق في الطريق إلى موقع الخدمة.';
      }
      return 'تم تعيين الفريق وسيبدأ التحرك في الوقت المناسب.';
    }
    if (status == CleaningBookingStatus.awaitingStartVerification) {
      return 'وصل العامل. أكمل رمز التحقق قبل بدء العمل.';
    }
    if (status == CleaningBookingStatus.awaitingWorkerStartConfirmation) {
      return 'تم التحقق من الرمز وننتظر تأكيد بدء العمل.';
    }
    if (status == CleaningBookingStatus.inProgress) {
      return 'الخدمة قيد التنفيذ الآن.';
    }
    if (status == CleaningBookingStatus.awaitingCustomerCompletion) {
      return 'أبلغ الفريق بانتهاء العمل. راجع الإكمال قبل الإغلاق.';
    }
    if (status == CleaningBookingStatus.timeExtensionRequested) {
      return 'تم إرسال طلب تمديد الوقت وننتظر رد العامل.';
    }
    if (status == CleaningBookingStatus.completed) {
      return 'اكتملت الخدمة ويمكنك مراجعة التقييم.';
    }
    return 'تابع حالة الطلب من هذا المسار.';
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = isCompleted || isCurrent;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? SharedPlatformColors.primary
                        : SharedPlatformColors.neutralSoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? SharedPlatformColors.primary
                          : SharedPlatformColors.border,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : isCurrent
                      ? const Icon(Icons.circle, size: 7, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isCompleted
                          ? SharedPlatformColors.cleaning
                          : SharedPlatformColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Text(
                label,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: isCurrent
                      ? SharedPlatformColors.primary
                      : active
                      ? SharedPlatformColors.ink
                      : SharedPlatformColors.muted,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledTimelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharedPlatformColors.dangerSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: SharedPlatformColors.danger),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'تم إلغاء هذا الطلب. لا توجد خطوات تشغيلية متبقية.',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF7A271A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
