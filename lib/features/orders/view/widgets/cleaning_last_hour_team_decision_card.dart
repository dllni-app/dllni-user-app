import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import 'v7_order_detail_components.dart';

/// API-owned last-hour decision. Only the backend may mark this choice eligible.
/// Confirm irreversible changes before submitting them to the booking service.
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

  Future<void> _confirmChoice(
    BuildContext context,
    String choice,
    int? workerId,
  ) async {
    final assignAll = choice == 'all_tasks';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('cleaning_last_hour_confirm_dialog'),
        title: Text(
          assignAll ? 'تأكيد تنفيذ جميع المهام' : 'تأكيد توزيع المهام',
        ),
        content: Text(
          assignAll
              ? 'سيتم إسناد جميع مهام الطلب وغرفه إلى العامل الذي قبل الطلب، وسيصبح عدد العمال المطلوبين عاملاً واحداً. سيُبلَّغ العامل بالتغيير. راجع تفاصيل الطلب بعد التأكيد لمعرفة أي تحديثات.'
              : 'سيبقى كل عامل على المهام المحددة له، ويستمر البحث عن العمال الناقصين. لن تُنقل مهامهم إلى العمال الحاليين تلقائياً.',
        ),
        actions: [
          TextButton(
            key: const Key('cleaning_last_hour_dismiss'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            key: const Key('cleaning_last_hour_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تأكيد القرار'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await onChoose(choice, workerId);
    }
  }

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
      subtitle: 'الطلب بحاجة إلى قرارك قبل الموعد المحدد للخدمة.',
      leading: const Icon(
        Icons.assignment_turned_in_outlined,
        color: Color(0xFF0A7F8C),
        size: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            canAssignAll
                ? 'قبل عامل واحد طلبك ولم يكتمل العدد المطلوب. هل تريد أن ينفّذ هذا العامل جميع المهام، أم نتابع البحث عن بقية العمال؟'
                : 'قبل عدة عمال طلبك ولم يكتمل العدد المطلوب. يمكنك الإبقاء على توزيع مهامهم الحالي ومتابعة البحث عن البقية.',
            style: const TextStyle(
              fontSize: 13,
              color: SharedPlatformColors.ink,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          if (canAssignAll) ...[
            FilledButton(
              key: const Key('cleaning_last_hour_assign_all'),
              onPressed: isSubmitting
                  ? null
                  : () => _confirmChoice(context, 'all_tasks', ids.first),
              style: FilledButton.styleFrom(
                backgroundColor: SharedPlatformColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('تنفيذ جميع المهام'),
            ),
            const SizedBox(height: 9),
          ],
          OutlinedButton(
            key: const Key('cleaning_last_hour_keep_assignment'),
            onPressed: isSubmitting
                ? null
                : () => _confirmChoice(context, 'assigned_only', null),
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
