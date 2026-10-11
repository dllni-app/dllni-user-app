import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import 'v7_order_detail_components.dart';

/// API-owned last-hour decision. This component only presents the permitted
/// choices and sends the selected action to its existing controller.
class CleaningLastHourTeamDecisionCard extends StatelessWidget {
  const CleaningLastHourTeamDecisionCard({
    super.key,
    required this.decision,
    required this.onChoose,
    this.isSubmitting = false,
  });
  final Map<String, dynamic> decision;
  final Future<void> Function(String choice, int? workerId) onChoose;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    if (decision['required'] != true) return const SizedBox.shrink();
    final ids = (decision['workerIds'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((i) => i.toInt())
        .where((i) => i > 0)
        .toList();
    if (ids.isEmpty) return const SizedBox.shrink();
    final canAssignAll = ids.length == 1;
    return V7OrderPanel(
      key: const Key('cleaning_last_hour_decision'),
      title: 'اختيار طريقة تنفيذ المهام',
      subtitle: 'اختر ما يناسبك قبل موعد الخدمة.',
      leading: const Icon(
        Icons.assignment_turned_in_outlined,
        color: Color(0xFF0A7F8C),
        size: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'هل تفضل أن ينجز العامل الذي قبل طلبك كل المهام، أم يكتفي بالمهام المحددة له؟',
            style: TextStyle(
              fontSize: 13,
              color: SharedPlatformColors.ink,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('cleaning_last_hour_assign_all'),
            onPressed: isSubmitting || !canAssignAll
                ? null
                : () => onChoose('all_tasks', ids.first),
            style: FilledButton.styleFrom(
              backgroundColor: SharedPlatformColors.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('تنفيذ جميع المهام'),
          ),
          if (!canAssignAll) ...[
            const SizedBox(height: 6),
            const Text(
              'هذا الخيار متاح عند قبول عامل واحد للطلب.',
              style: TextStyle(color: SharedPlatformColors.muted, fontSize: 11),
            ),
          ],
          const SizedBox(height: 9),
          OutlinedButton(
            key: const Key('cleaning_last_hour_keep_assignment'),
            onPressed: isSubmitting
                ? null
                : () => onChoose('assigned_only', null),
            style: OutlinedButton.styleFrom(
              foregroundColor: SharedPlatformColors.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('الالتزام بالمهام المحددة'),
          ),
          if (isSubmitting) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: SharedPlatformColors.cleaning,
              minHeight: 3,
            ),
          ],
        ],
      ),
    );
  }
}
