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

  static const Color _screenBlue = Color(0xFF1E2A78);
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  final List<PreviousWorkerModel> workers;
  final int? selectedWorkerId;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<int?> onSelectWorker;
  final ValueChanged<PreviousWorkerModel> onOpenWorkerProfile;

  String? _workerSubtitle(PreviousWorkerModel worker) {
    final rating = worker.ratings?.average ?? worker.rating;
    if (rating != null && rating > 0) {
      return 'التقييم: ${rating.toStringAsFixed(1)}';
    }
    final lastService = worker.lastServiceDate?.trim();
    if (lastService != null && lastService.isNotEmpty) {
      return 'آخر خدمة: $lastService';
    }
    return null;
  }

  void _toggleWorker(PreviousWorkerModel worker) {
    final id = worker.id;
    onSelectWorker(selectedWorkerId == id ? null : id);
  }

  @override
  Widget build(BuildContext context) {
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
          else if (workers.isEmpty)
            AppText.bodySmall('لا يوجد عمال سابقون حالياً', color: const Color(0xFF6B7280), textAlign: TextAlign.right)
          else
            Column(
              children: [
                for (var i = 0; i < workers.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _WorkerSelectionCard(
                    worker: workers[i],
                    isSelected: selectedWorkerId == workers[i].id,
                    subtitle: _workerSubtitle(workers[i]),
                    onToggle: () => _toggleWorker(workers[i]),
                    onOpenDetails: () => onOpenWorkerProfile(workers[i]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _WorkerSelectionCard extends StatelessWidget {
  const _WorkerSelectionCard({
    required this.worker,
    required this.isSelected,
    required this.subtitle,
    required this.onToggle,
    required this.onOpenDetails,
  });

  final PreviousWorkerModel worker;
  final bool isSelected;
  final String? subtitle;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? ClServicePreviousWorkersSectionWidget._screenBlue : ClServicePreviousWorkersSectionWidget._neutralBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
        leading: Checkbox(
          value: isSelected,
          activeColor: ClServicePreviousWorkersSectionWidget._screenBlue,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ClServicePreviousWorkersSectionWidget._screenBlue;
            }
            return null;
          }),
          onChanged: (_) => onToggle(),
        ),
        title: AppText.bodyMedium(
          worker.name ?? '-',
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle == null
            ? null
            : AppText.bodySmall(
                subtitle!,
                color: const Color(0xFF6B7280),
                textAlign: TextAlign.start,
              ),
        trailing: TextButton(
          onPressed: onOpenDetails,
          style: TextButton.styleFrom(
            foregroundColor: ClServicePreviousWorkersSectionWidget._screenBlue,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          ),
          child: const Text('تفاصيل'),
        ),
        onTap: onToggle,
      ),
    );
  }
}
