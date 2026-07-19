import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/previous_workers_response_model.dart';

class ClServicePreviousWorkersSectionWidget extends StatefulWidget {
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
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  final List<PreviousWorkerModel> workers;
  final List<int> selectedWorkerIds;
  final int? selectedWorkerId;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<int> onSelectWorker;
  final ValueChanged<PreviousWorkerModel> onOpenWorkerProfile;

  @override
  State<ClServicePreviousWorkersSectionWidget> createState() =>
      _ClServicePreviousWorkersSectionWidgetState();
}

class _ClServicePreviousWorkersSectionWidgetState
    extends State<ClServicePreviousWorkersSectionWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> get _effectiveSelectedWorkerIds {
    if (widget.selectedWorkerIds.isNotEmpty) return widget.selectedWorkerIds;
    final single = widget.selectedWorkerId;
    return single == null ? const <int>[] : <int>[single];
  }

  List<PreviousWorkerModel> get _filteredWorkers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.workers;
    return widget.workers.where((worker) {
      final name = worker.name?.trim().toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

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
    if (id == null) return;
    widget.onSelectWorker(id);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = _effectiveSelectedWorkerIds;
    final selectedCount = selectedIds.length;
    final filteredWorkers = _filteredWorkers;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            'هل تفضل العمل مجدداً مع عمال تعاملت معهم مسبقاً؟',
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
          if (selectedCount > 0) ...[
            const SizedBox(height: 4),
            AppText.bodySmall(
              'تم تحديد $selectedCount عامل مفضل',
              color: ClServicePreviousWorkersSectionWidget._screenBlue,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.right,
            ),
          ],
          const SizedBox(height: 10),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.errorMessage != null &&
              widget.errorMessage!.isNotEmpty)
            AppText.bodySmall(
              widget.errorMessage!,
              color: Colors.redAccent,
              textAlign: TextAlign.right,
            )
          else if (widget.workers.isEmpty)
            AppText.bodySmall(
              'لا يوجد عمال سابقون حالياً',
              color: const Color(0xFF6B7280),
              textAlign: TextAlign.right,
            )
          else ...[
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث عن عامل...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                suffixIcon: hasSearchQuery
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ClServicePreviousWorkersSectionWidget._neutralBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ClServicePreviousWorkersSectionWidget._screenBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (filteredWorkers.isEmpty)
              AppText.bodySmall(
                'لا توجد نتائج للبحث',
                color: const Color(0xFF6B7280),
                textAlign: TextAlign.right,
              )
            else
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredWorkers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];
                    return _WorkerSelectionCard(
                      worker: worker,
                      isSelected: selectedIds.contains(worker.id),
                      subtitle: _workerSubtitle(worker),
                      onToggle: () => _toggleWorker(worker),
                      onOpenDetails: () =>
                          widget.onOpenWorkerProfile(worker),
                    );
                  },
                ),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Material(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? ClServicePreviousWorkersSectionWidget._screenBlue
                    : ClServicePreviousWorkersSectionWidget._neutralBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor:
                          ClServicePreviousWorkersSectionWidget._screenBlue,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return ClServicePreviousWorkersSectionWidget
                              ._screenBlue;
                        }
                        return null;
                      }),
                      onChanged: (_) => onToggle(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                AppText.bodyMedium(
                  worker.name ?? '-',
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subtitle != null)
                  AppText.bodySmall(
                    subtitle!,
                    color: const Color(0xFF6B7280),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  const SizedBox(height: 16),
                const Spacer(),
                TextButton(
                  onPressed: onOpenDetails,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        ClServicePreviousWorkersSectionWidget._screenBlue,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('تفاصيل'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
