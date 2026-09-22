import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';
import 'multi_day_cleaning_order_details_content.dart' as content;

class MultiDayCleaningOrderDetailsScreen extends StatefulWidget {
  const MultiDayCleaningOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialSessionId,
    this.recurring = false,
  });

  final int orderId;
  final int? initialSessionId;
  final bool recurring;

  @override
  State<MultiDayCleaningOrderDetailsScreen> createState() =>
      _MultiDayCleaningOrderDetailsScreenState();
}

class _MultiDayCleaningOrderDetailsScreenState
    extends State<MultiDayCleaningOrderDetailsScreen> {
  CleaningBookingScheduleModel? _schedule;
  bool _changingWorker = false;
  int _contentVersion = 0;

  CleaningSessionRemoteDataSource get _sessions =>
      getIt<CleaningSessionRemoteDataSource>();

  List<_WorkerChangeCandidate> get _candidates {
    final schedule = _schedule;
    if (schedule == null) return const <_WorkerChangeCandidate>[];

    final result = <_WorkerChangeCandidate>[];
    for (final session in schedule.sessions) {
      final sessionId = session.id;
      final status = session.status.trim().toLowerCase();
      if (sessionId == null ||
          !_isFutureSession(session) ||
          session.hasStartedExecution ||
          (status != 'scheduled' && status != 'worker_assigned')) {
        continue;
      }

      for (final assignment in session.workerAssignments) {
        final workerId = assignment.workerId;
        final assignmentStatus = assignment.status?.trim().toLowerCase();
        if (workerId == null ||
            workerId <= 0 ||
            (assignmentStatus != 'accepted' &&
                assignmentStatus != 'accepted_waiting_for_order_start') ||
            assignment.startedTravelAt != null ||
            assignment.arrivedAt != null ||
            assignment.startApprovedAt != null ||
            assignment.workStartedAt != null) {
          continue;
        }

        result.add(
          _WorkerChangeCandidate(
            session: session,
            assignment: assignment,
            recurring: widget.recurring,
          ),
        );
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _refreshChangeOptions();
  }

  @override
  void didUpdateWidget(covariant MultiDayCleaningOrderDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId ||
        oldWidget.recurring != widget.recurring) {
      _schedule = null;
      _contentVersion++;
      _refreshChangeOptions();
    }
  }

  Future<void> _refreshChangeOptions() async {
    try {
      final envelope = await _sessions.fetchBookingSchedule(widget.orderId);
      if (!mounted) return;
      setState(() => _schedule = envelope.schedule);
    } catch (_) {
      // The underlying details screen owns the primary loading/error UX. Failure
      // here only hides the optional worker-change overlay until the next refresh.
    }
  }

  bool _isFutureSession(CleaningBookingSessionModel session) {
    final date = session.date;
    final rawTime = session.time?.trim();
    if (date == null || rawTime == null || rawTime.isEmpty) return false;

    final parts = rawTime.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    if (hour == null || minute == null) return false;

    final startsAt = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
      second,
    );
    return startsAt.isAfter(DateTime.now());
  }

  Future<void> _openWorkerChangeSheet() async {
    if (_changingWorker) return;
    final candidates = _candidates;
    if (candidates.isEmpty) return;

    final selected = await showModalBottomSheet<_WorkerChangeCandidate>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
                child: Text(
                  widget.recurring
                      ? 'تغيير عامل في زيارة قادمة'
                      : 'تغيير عامل في يوم قادم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                child: Text(
                  widget.recurring
                      ? 'اختر العامل والزيارة المطلوبة فقط. لن تتأثر الزيارات الأخرى أو العمال الآخرون.'
                      : 'اختر العامل واليوم المطلوب فقط. لن تتأثر الأيام المنفذة أو العمال الآخرون.',
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 18),
                  itemCount: candidates.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_search_outlined),
                      ),
                      title: Text(candidate.workerName),
                      subtitle: Text(candidate.sessionLabel),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(sheetContext).pop(candidate),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selected == null) return;
    await _requestWorkerChange(selected);
  }

  Future<void> _requestWorkerChange(_WorkerChangeCandidate candidate) async {
    final reason = await _askReason(candidate);
    if (!mounted || reason == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد طلب الاستبدال'),
        content: Text(
          widget.recurring
              ? 'سيتم تحرير ${candidate.workerName} من ${candidate.sessionLabel} فقط، ثم تصبح الخانة متاحة لعامل بديل. بقية الزيارات والعمال لن تتغير.'
              : 'سيتم تحرير ${candidate.workerName} من ${candidate.sessionLabel} فقط، ثم تصبح الخانة متاحة لعامل بديل. بقية أيام المناسبة والعمال لن تتغير.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تأكيد الاستبدال'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _changingWorker = true);
    try {
      final envelope = await _sessions.changeWorkers(
        orderId: widget.orderId,
        changes: <Map<String, dynamic>>[
          <String, dynamic>{
            'sessionId': candidate.session.id,
            'workerIds': <int>[candidate.assignment.workerId!],
          },
        ],
        reason: reason,
      );
      if (!mounted) return;

      setState(() {
        _schedule = envelope.schedule;
        _contentVersion++;
      });
      if (envelope.schedule == null) {
        await _refreshChangeOptions();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحرير ${candidate.workerName} من اليوم المحدد، وسيتم البحث عن بديل للخانة المتاحة.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.recurring
                ? 'تعذر تغيير العامل. حدّث الزيارات وتأكد أن العامل لم يبدأ التوجه ثم حاول مرة أخرى.'
                : 'تعذر تغيير العامل. حدّث تفاصيل المناسبة وتأكد أن العامل لم يبدأ التوجه ثم حاول مرة أخرى.',
          ),
        ),
      );
      await _refreshChangeOptions();
    } finally {
      if (mounted) setState(() => _changingWorker = false);
    }
  }

  Future<String?> _askReason(_WorkerChangeCandidate candidate) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final reason = controller.text.trim();
            return AlertDialog(
              title: Text('سبب تغيير ${candidate.workerName}'),
              content: TextField(
                controller: controller,
                minLines: 2,
                maxLines: 5,
                maxLength: 1000,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  hintText: 'اكتب سبب طلب استبدال العامل',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: reason.isEmpty
                      ? null
                      : () => Navigator.of(dialogContext).pop(reason),
                  child: const Text('متابعة'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: content.MultiDayCleaningOrderDetailsScreen(
            key: ValueKey<int>(_contentVersion),
            orderId: widget.orderId,
            initialSessionId: widget.initialSessionId,
            recurring: widget.recurring,
          ),
        ),
        if (_candidates.isNotEmpty)
          PositionedDirectional(
            end: 16,
            bottom: 20,
            child: SafeArea(
              child: FloatingActionButton.extended(
                heroTag: widget.recurring
                    ? 'recurring-worker-change-${widget.orderId}'
                    : 'event-worker-change-${widget.orderId}',
                onPressed: _changingWorker ? null : _openWorkerChangeSheet,
                icon: _changingWorker
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.manage_accounts_outlined),
                label: const Text('تغيير العامل'),
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkerChangeCandidate {
  const _WorkerChangeCandidate({
    required this.session,
    required this.assignment,
    required this.recurring,
  });

  final CleaningBookingSessionModel session;
  final CleaningSessionWorkerAssignmentModel assignment;
  final bool recurring;

  String get workerName {
    final name = assignment.workerName?.trim();
    return name?.isNotEmpty == true ? name! : 'العامل #${assignment.workerId}';
  }

  String get sessionLabel {
    final date = session.date;
    final dateText = date == null
        ? ''
        : '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final time = session.time?.trim();
    final parts = <String>[
      recurring ? 'الزيارة ${session.sequence}' : 'اليوم ${session.sequence}',
    ];
    if (dateText.isNotEmpty) parts.add(dateText);
    if (time?.isNotEmpty == true) parts.add(time!);
    return parts.join(' • ');
  }
}
