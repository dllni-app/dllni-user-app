import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';

class CleaningScheduleChangeResolutionCard extends StatefulWidget {
  const CleaningScheduleChangeResolutionCard({
    required this.change,
    required this.requiredWorkers,
    required this.onResolved,
    super.key,
  });

  final CleaningScheduleChangeRequestModel change;
  final int requiredWorkers;
  final VoidCallback onResolved;

  @override
  State<CleaningScheduleChangeResolutionCard> createState() =>
      _CleaningScheduleChangeResolutionCardState();
}

class _CleaningScheduleChangeResolutionCardState
    extends State<CleaningScheduleChangeResolutionCard> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final change = widget.change;
    return Semantics(
      container: true,
      label: change.isRejected
          ? 'طلب تعديل مواعيد مرفوض ويحتاج إلى قرارك'
          : 'طلب تعديل مواعيد بانتظار موافقة العمال',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: change.isRejected
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  change.isRejected
                      ? Icons.event_busy_outlined
                      : Icons.pending_actions_outlined,
                  color: change.isRejected
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change.isRejected
                            ? 'تعذر اعتماد المواعيد الجديدة'
                            : 'المواعيد الجديدة بانتظار الموافقة',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        change.isRejected
                            ? 'اختر عاملاً بديلاً، أو تراجع عن التعديل، أو ألغِ الجلسات المتأثرة.'
                            : 'لن تتغير الجلسات الحالية حتى يوافق جميع العمال المتأثرين.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (change.sessions.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final session in change.sessions.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${session.date} • ${session.time}'),
                      ),
                    ],
                  ),
                ),
            ],
            if (change.priceDelta != 0) ...[
              const SizedBox(height: 6),
              Text(
                'فرق السعر: ${change.priceDelta.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (change.decisions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: change.decisions
                    .map((decision) {
                      final accepted = decision.decision == 'accepted';
                      final rejected = decision.decision == 'rejected';
                      return Chip(
                        avatar: Icon(
                          accepted
                              ? Icons.check_circle_outline
                              : rejected
                              ? Icons.cancel_outlined
                              : Icons.schedule_outlined,
                          size: 18,
                        ),
                        label: Text(
                          '${decision.workerName ?? 'عامل'}: ${accepted
                              ? 'موافق'
                              : rejected
                              ? 'رافض'
                              : 'بانتظار الرد'}',
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (change.isRejected) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _chooseReplacement,
                  icon: const Icon(Icons.person_search_outlined),
                  label: const Text('اختيار عامل بديل'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _resolve('revert'),
                  child: const Text('التراجع عن التعديل'),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _busy ? null : _confirmCancellation,
                  child: Text(
                    'إلغاء الجلسات المتأثرة',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _chooseReplacement() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    List<CleaningReplacementWorkerOptionModel> workers;
    try {
      workers = await getIt<CleaningSessionRemoteDataSource>()
          .fetchScheduleChangeReplacementOptions(widget.change.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'تعذر تحميل العمال المتاحين. حاول مرة أخرى.';
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (workers.isEmpty) {
      setState(
        () => _error = 'لا يوجد عامل بديل متاح للمواعيد المقترحة حالياً.',
      );
      return;
    }

    final selected = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ReplacementWorkerSheet(
        workers: workers,
        requiredWorkers: widget.requiredWorkers,
      ),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    await _resolve('replace', replacementWorkerIds: selected);
  }

  Future<void> _confirmCancellation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الجلسات المتأثرة؟'),
        content: const Text(
          'سيتم إلغاء الجلسات المشمولة بطلب التعديل. لا يمكن التراجع عن هذا القرار من هذه الشاشة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _resolve('cancel');
  }

  Future<void> _resolve(
    String resolution, {
    List<int> replacementWorkerIds = const <int>[],
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await getIt<CleaningSessionRemoteDataSource>().resolveScheduleChange(
        changeRequestId: widget.change.id,
        resolution: resolution,
        replacementWorkerIds: replacementWorkerIds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ قرارك وتحديث الحجز.')),
      );
      widget.onResolved();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'تعذر حفظ القرار. تحقق من الاتصال وحاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ReplacementWorkerSheet extends StatefulWidget {
  const _ReplacementWorkerSheet({
    required this.workers,
    required this.requiredWorkers,
  });

  final List<CleaningReplacementWorkerOptionModel> workers;
  final int requiredWorkers;

  @override
  State<_ReplacementWorkerSheet> createState() =>
      _ReplacementWorkerSheetState();
}

class _ReplacementWorkerSheetState extends State<_ReplacementWorkerSheet> {
  final Set<int> _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final maximum = widget.requiredWorkers.clamp(1, 20);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        18,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختيار عامل بديل',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('يمكنك اختيار حتى $maximum من العمال المتاحين لهذه المواعيد.'),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.workers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final worker = widget.workers[index];
                final checked = _selected.contains(worker.id);
                return CheckboxListTile(
                  value: checked,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(worker.name),
                  subtitle: worker.rating > 0
                      ? Text('التقييم ${worker.rating.toStringAsFixed(1)}')
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (value == true && _selected.length < maximum) {
                        _selected.add(worker.id);
                      } else if (value != true) {
                        _selected.remove(worker.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.pop(context, _selected.toList()),
              child: const Text('اعتماد العامل المحدد'),
            ),
          ),
        ],
      ),
    );
  }
}
