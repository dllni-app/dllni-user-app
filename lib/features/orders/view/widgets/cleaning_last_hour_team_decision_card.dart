import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Presented only when the backend requests the customer's last-hour choice.
/// This widget never changes assignments locally; the server owns the decision.
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
    final workerIds = (decision['workerIds'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .where((value) => value > 0)
        .toList();
    if (workerIds.isEmpty) return const SizedBox.shrink();
    final canAssignAll = workerIds.length == 1;

    return Container(
      key: const Key('cleaning_last_hour_decision'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E9),
        border: Border.all(color: const Color(0xFFF4D99A)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notification_important_outlined,
                color: Color(0xFF9F6616),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تأكيد مهام عامل التنظيف',
                  style: TextStyle(
                    color: SharedPlatformColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'اقترب موعد الخدمة ولم يكتمل الفريق المطلوب. هل تريد أن ينفذ العامل الذي وافق جميع المهام، أم يلتزم بالمهام المحددة له فقط؟',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'قد تتغير مدة التنفيذ والتكلفة بعد تحديث المهام، وستظهر التفاصيل المحدثة في الطلب.',
            textAlign: TextAlign.start,
            style: TextStyle(color: SharedPlatformColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('cleaning_last_hour_assign_all'),
            onPressed: isSubmitting || !canAssignAll
                ? null
                : () => onChoose('all_tasks', workerIds.first),
            style: FilledButton.styleFrom(
              backgroundColor: SharedPlatformColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('إسناد جميع المهام للعامل'),
          ),
          if (!canAssignAll) ...[
            const SizedBox(height: 6),
            const Text(
              'يمكن إسناد جميع المهام عندما يكون هناك عامل واحد وافق على الطلب.',
              textAlign: TextAlign.start,
              style: TextStyle(color: SharedPlatformColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('cleaning_last_hour_keep_assignment'),
            onPressed: isSubmitting
                ? null
                : () => onChoose('assigned_only', null),
            style: OutlinedButton.styleFrom(
              foregroundColor: SharedPlatformColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('الإبقاء على مهام العامل المحددة'),
          ),
          if (isSubmitting) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
        ],
      ),
    );
  }
}
