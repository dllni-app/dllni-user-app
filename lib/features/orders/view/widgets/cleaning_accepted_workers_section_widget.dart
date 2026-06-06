import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

class CleaningAcceptedWorkersSectionWidget extends StatelessWidget {
  const CleaningAcceptedWorkersSectionWidget({
    required this.assignments,
    this.onCallWorker,
    super.key,
  });

  final List<CleaningWorkerAssignmentModel> assignments;
  final ValueChanged<String?>? onCallWorker;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            'فريق العمل',
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(height: 4),
          AppText.bodySmall(
            'العمال الذين قبلوا الطلب',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < assignments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _WorkerTile(
              assignment: assignments[i],
              onCallWorker: onCallWorker,
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkerTile extends StatelessWidget {
  const _WorkerTile({
    required this.assignment,
    this.onCallWorker,
  });

  final CleaningWorkerAssignmentModel assignment;
  final ValueChanged<String?>? onCallWorker;

  @override
  Widget build(BuildContext context) {
    final worker = assignment.worker;
    final name = worker?.name ?? 'عامل';
    final rating = worker?.averageRating;
    final roomCount = assignment.roomCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: worker?.avatarUrl == null
                ? null
                : NetworkImage(worker!.avatarUrl!),
            child: worker?.avatarUrl == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  name,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText.bodySmall(
                  [
                    if (rating != null) '⭐ ${rating.toStringAsFixed(1)}',
                    if (roomCount > 0) '$roomCount غرف',
                  ].join(' • '),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          if (onCallWorker != null && worker?.phone != null)
            InkWell(
              onTap: () => onCallWorker!(worker!.phone),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.call, size: 18, color: Color(0xFF111827)),
              ),
            ),
        ],
      ),
    );
  }
}
