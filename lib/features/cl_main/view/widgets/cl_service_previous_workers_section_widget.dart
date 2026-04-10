import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/previous_workers_response_model.dart';

class ClServicePreviousWorkersSectionWidget extends StatelessWidget {
  const ClServicePreviousWorkersSectionWidget({
    required this.workers,
    required this.selectedWorkerId,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelectWorker,
    required this.onOpenWorkerProfile,
    super.key,
  });

  final List<PreviousWorkerModel> workers;
  final int? selectedWorkerId;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<int?> onSelectWorker;
  final ValueChanged<PreviousWorkerModel> onOpenWorkerProfile;

  Color _avatarColor(int index) {
    const colors = <Color>[Color(0xFFF4D9E2), Color(0xFFD8F3F2), Color(0xFFD4EDEA), Color(0xFFF6E8DE)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final visibleWorkers = workers.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            'هل تفضل العمل مجدداً مع عماليين قد تعاملت معهم مسبقاً ؟',
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && errorMessage!.isNotEmpty)
            AppText.bodySmall(errorMessage!, color: Colors.redAccent, textAlign: TextAlign.right)
          else if (visibleWorkers.isEmpty)
            AppText.bodySmall('لا يوجد عمال سابقون حالياً', color: const Color(0xFF6B7280), textAlign: TextAlign.right)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: visibleWorkers
                  .asMap()
                  .entries
                  .map(
                    (entry) => Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final id = entry.value.id;
                          onSelectWorker(selectedWorkerId == id ? null : id);
                          onOpenWorkerProfile(entry.value);
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _avatarColor(entry.key),
                              backgroundImage: entry.value.profileImage == null ? null : NetworkImage(entry.value.profileImage!),
                              child: entry.value.profileImage != null ? null :  Icon(selectedWorkerId == entry.value.id ? Icons.check : Icons.person, size: 24, color: const Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 6),
                            AppText.bodySmall(
                              entry.value.name ?? '-',
                              color: const Color(0xFF111827),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
