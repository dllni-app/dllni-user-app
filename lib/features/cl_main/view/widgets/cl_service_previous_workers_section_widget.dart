import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/previous_workers_response_model.dart';

class ClServicePreviousWorkersSectionWidget extends StatelessWidget {
  const ClServicePreviousWorkersSectionWidget({
    required this.workers,
    this.selectedWorkerIds = const <int>[],
    this.selectedWorkerId,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelectWorker,
    required this.onOpenWorkerProfile,
    super.key,
  });

  static const Color _screenBlue = Color(0xFF1E2A78);
  static const Color _teal = Color(0xFF0CBBC7);
  static const Color _neutralBorder = Color(0xFFE5E7EB);
  static const Color _mutedText = Color(0xFF6B7280);

  final List<PreviousWorkerModel> workers;
  final List<int> selectedWorkerIds;
  final int? selectedWorkerId;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<int> onSelectWorker;
  final ValueChanged<PreviousWorkerModel> onOpenWorkerProfile;

  List<int> get _effectiveSelectedWorkerIds {
    if (selectedWorkerIds.isNotEmpty) return selectedWorkerIds;
    final single = selectedWorkerId;
    return single == null ? const <int>[] : <int>[single];
  }

  String? _workerSubtitle(PreviousWorkerModel worker) {
    final rating = worker.ratings?.average ?? worker.rating;
    if (rating != null && rating > 0) {
      return 'التقييم ${rating.toStringAsFixed(1)}';
    }
    final lastService = worker.lastServiceDate?.trim();
    if (lastService != null && lastService.isNotEmpty) {
      return 'آخر خدمة $lastService';
    }
    return null;
  }

  String _selectionHint(int selectedCount) {
    if (selectedCount == 0) {
      return 'اختيار عامل مفضل يحدّث السعر وهامش الإدارة ولا يغيّر عدد العمال المطلوب.';
    }
    return 'تم تحديد $selectedCount عامل مفضل. اضغط على العامل المحدد مرة أخرى لإزالته من القائمة.';
  }

  void _toggleWorker(PreviousWorkerModel worker) {
    final id = worker.id;
    if (id == null) return;
    onSelectWorker(id);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = _effectiveSelectedWorkerIds;
    final selectedCount = selectedIds.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _neutralBorder),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _teal.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services_outlined,
                  color: _teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyLarge(
                      'مقدم خدمة مفضل',
                      color: _screenBlue,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 3),
                    AppText.bodySmall(
                      _selectionHint(selectedCount),
                      color: _mutedText,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (selectedCount > 0) ...[
            const SizedBox(height: 10),
            _SelectedWorkersStrip(
              selectedCount: selectedCount,
              selectedWorkers: workers
                  .where((worker) => selectedIds.contains(worker.id))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && errorMessage!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: AppText.bodySmall(
                errorMessage!,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            )
          else if (workers.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neutralBorder),
              ),
              child: AppText.bodySmall(
                'لا يوجد عمال سابقون حالياً، وسيتم إرسال الطلب للنظام بشكل عادي.',
                color: _mutedText,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < workers.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _WorkerSelectionCard(
                    worker: workers[i],
                    isSelected: selectedIds.contains(workers[i].id),
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

class _SelectedWorkersStrip extends StatelessWidget {
  const _SelectedWorkersStrip({
    required this.selectedCount,
    required this.selectedWorkers,
  });

  final int selectedCount;
  final List<PreviousWorkerModel> selectedWorkers;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            'المحددون ($selectedCount)',
            color: ClServicePreviousWorkersSectionWidget._screenBlue,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.start,
          ),
          if (selectedWorkers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedWorkers.map((worker) {
                return Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: AppText.bodySmall(
                    worker.name ?? 'عامل #${worker.id ?? '-'}',
                    color: const Color(0xFF1E40AF),
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.start,
                  ),
                );
              }).toList(growable: false),
            ),
          ],
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

  String get _avatarLetter {
    final name = worker.name?.trim();
    if (name == null || name.isEmpty) return 'ع';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDFA) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? ClServicePreviousWorkersSectionWidget._teal
                  : ClServicePreviousWorkersSectionWidget._neutralBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 8, 9),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Checkbox(
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
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: isSelected
                    ? ClServicePreviousWorkersSectionWidget._teal.withAlpha(36)
                    : const Color(0xFFE5E7EB),
                child: Text(
                  _avatarLetter,
                  style: const TextStyle(
                    color: ClServicePreviousWorkersSectionWidget._screenBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      worker.name ?? '-',
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      AppText.bodySmall(
                        subtitle!,
                        color: ClServicePreviousWorkersSectionWidget._mutedText,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: onOpenDetails,
                style: TextButton.styleFrom(
                  foregroundColor: ClServicePreviousWorkersSectionWidget._screenBlue,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                  minimumSize: const Size(56, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('تفاصيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
