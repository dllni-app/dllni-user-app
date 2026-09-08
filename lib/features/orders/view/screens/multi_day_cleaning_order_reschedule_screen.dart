import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';

class MultiDayCleaningOrderRescheduleScreen extends StatefulWidget {
  const MultiDayCleaningOrderRescheduleScreen({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<MultiDayCleaningOrderRescheduleScreen> createState() =>
      _MultiDayCleaningOrderRescheduleScreenState();
}

class _MultiDayCleaningOrderRescheduleScreenState
    extends State<MultiDayCleaningOrderRescheduleScreen> {
  CleaningMultiDayOrderEnvelope? _envelope;
  bool _loading = true;
  int? _savingSessionId;
  String? _error;
  bool _changed = false;

  CleaningSessionRemoteDataSource get _remote =>
      getIt<CleaningSessionRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final envelope = await _remote.fetchBookingSchedule(widget.orderId);
      if (!mounted) return;

      setState(() {
        _envelope = envelope;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل أيام المناسبة. حاول مرة أخرى.';
      });
    }
  }

  List<CleaningBookingSessionModel> get _sessions {
    final items = List<CleaningBookingSessionModel>.of(
      _envelope?.schedule?.sessions ?? const <CleaningBookingSessionModel>[],
    );
    items.sort((left, right) {
      final leftDate = left.date;
      final rightDate = right.date;
      if (leftDate != null && rightDate != null) {
        final dateCompare = leftDate.compareTo(rightDate);
        if (dateCompare != 0) return dateCompare;
      }
      return left.sequence.compareTo(right.sequence);
    });
    return items;
  }

  bool get _hasEditableSession =>
      _sessions.any((session) => session.canReschedule == true);

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _editSession(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null ||
        session.canReschedule != true ||
        _savingSessionId != null) {
      return;
    }

    final initialDate = session.date ?? _today();
    final draft = await showModalBottomSheet<_SessionScheduleDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _SessionScheduleEditor(
        sequence: session.sequence,
        initialDate: initialDate.isBefore(_today()) ? _today() : initialDate,
        initialTime: session.time ?? '09:00',
      ),
    );
    if (!mounted || draft == null) return;

    if (_duplicatesAnotherSession(session, draft)) {
      _showMessage('يوجد يوم آخر في التاريخ والوقت نفسيهما. اختر موعداً مختلفاً.');
      return;
    }

    setState(() {
      _savingSessionId = sessionId;
      _error = null;
    });

    try {
      final envelope = await _remote.rescheduleSession(
        orderId: widget.orderId,
        sessionId: sessionId,
        date: draft.date,
        time: draft.time,
      );
      if (!mounted) return;

      setState(() {
        _envelope = envelope.schedule != null ? envelope : _envelope;
        _savingSessionId = null;
        _changed = true;
      });

      if (envelope.schedule == null) {
        await _load();
      }
      if (!mounted) return;

      _showMessage('تم تحديث موعد هذا اليوم فقط.');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savingSessionId = null;
        _error =
            'تعذر تعديل هذا اليوم. قد يكون العامل بدأ التنقل أو أصبح الموعد متعارضاً مع حجز آخر.';
      });
    }
  }

  bool _duplicatesAnotherSession(
    CleaningBookingSessionModel editing,
    _SessionScheduleDraft draft,
  ) {
    for (final session in _sessions) {
      if (session.id == editing.id) continue;
      final date = session.date;
      final time = session.time?.trim();
      if (date == null || time == null || time.isEmpty) continue;

      if (_sameDate(date, draft.date) && _normalizeTime(time) == draft.time) {
        return true;
      }
    }
    return false;
  }

  bool _sameDate(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;

  String _normalizeTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length < 2) return value.trim();
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _timeLabel(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return _normalizeTime(value);
  }

  String _statusLabel(CleaningBookingSessionModel session) {
    final label = session.statusLabel?.trim();
    if (label != null && label.isNotEmpty) return label;

    return switch (session.status.trim().toLowerCase()) {
      'scheduled' => 'مجدولة',
      'worker_assigned' => 'تم تعيين العامل',
      'awaiting_start_verification' => 'بانتظار التحقق',
      'awaiting_worker_start_confirmation' => 'بانتظار بدء العامل',
      'in_progress' => 'قيد التنفيذ',
      'awaiting_customer_completion' => 'بانتظار تأكيد الإكمال',
      'completed' => 'مكتملة',
      'cancelled' => 'ملغاة',
      'skipped' => 'متخطاة',
      _ => session.status,
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _handleBack() async {
    Navigator.of(context).pop(_changed);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(
          title: const Text('تعديل أيام المناسبة'),
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _error != null && sessions.isEmpty
            ? _ErrorState(message: _error!, onRetry: _load)
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _InfoBanner(hasEditableSession: _hasEditableSession),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffFECACA)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xff991B1B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${sessions.length} أيام ضمن نفس المناسبة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (sessions.isEmpty)
                      const _EmptyState()
                    else
                      ...sessions.map((session) {
                        final busy = _savingSessionId == session.id;
                        final editable = session.canReschedule == true;
                        final workers = session.workerAssignments
                            .map((assignment) => assignment.workerName?.trim())
                            .whereType<String>()
                            .where((name) => name.isNotEmpty)
                            .toSet()
                            .join('، ');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: editable
                                    ? const Color(0xffBFDBFE)
                                    : const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'اليوم ${session.sequence}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    _StatusChip(label: _statusLabel(session)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _ValueRow(
                                  label: 'التاريخ',
                                  value: _dateLabel(session.date),
                                ),
                                const SizedBox(height: 7),
                                _ValueRow(
                                  label: 'الوقت',
                                  value: _timeLabel(session.time),
                                ),
                                const SizedBox(height: 7),
                                _ValueRow(
                                  label: 'المدة',
                                  value: '${_hours(session.hours)} ساعة',
                                ),
                                if (workers.isNotEmpty) ...[
                                  const SizedBox(height: 7),
                                  _ValueRow(label: 'العامل', value: workers),
                                ],
                                const SizedBox(height: 12),
                                if (editable)
                                  FilledButton.icon(
                                    onPressed: busy || _savingSessionId != null
                                        ? null
                                        : () => _editSession(session),
                                    icon: busy
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit_calendar_outlined,
                                          ),
                                    label: const Text('تعديل موعد هذا اليوم'),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'هذا اليوم غير قابل لتعديل الموعد في حالته الحالية.',
                                      style: TextStyle(
                                        color: Color(0xff6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
    );
  }

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

class _SessionScheduleDraft {
  const _SessionScheduleDraft({required this.date, required this.time});

  final DateTime date;
  final String time;
}

class _SessionScheduleEditor extends StatefulWidget {
  const _SessionScheduleEditor({
    required this.sequence,
    required this.initialDate,
    required this.initialTime,
  });

  final int sequence;
  final DateTime initialDate;
  final String initialTime;

  @override
  State<_SessionScheduleEditor> createState() => _SessionScheduleEditorState();
}

class _SessionScheduleEditorState extends State<_SessionScheduleEditor> {
  late DateTime _date;
  late String _time;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _time = _normalizeTime(widget.initialTime);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDate() async {
    final today = _today();
    final selected = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
      initialDate: _date.isBefore(today) ? today : _date,
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 9,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (selected == null || !mounted) return;

    setState(() {
      _time =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    });
  }

  String _normalizeTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length < 2) return '09:00';
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تعديل موعد اليوم ${widget.sequence}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'سيتم تعديل هذا اليوم فقط. الأيام المكتملة أو الجارية وبقية مواعيد المناسبة لن تتغير.',
            style: TextStyle(color: Color(0xff6B7280)),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(_dateLabel(_date)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule_outlined),
            label: Text(_time),
          ),
          const SizedBox(height: 12),
          const Text(
            'مدة اليوم تبقى كما هي بعد تعيين عامل، لحماية تسوية العامل والتسعير المرتبط بهذه الجلسة.',
            style: TextStyle(
              color: Color(0xff6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(
              _SessionScheduleDraft(date: _date, time: _time),
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ موعد هذا اليوم'),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.hasEditableSession});

  final bool hasEditableSession;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasEditableSession
            ? const Color(0xffEFF6FF)
            : const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasEditableSession
              ? const Color(0xffBFDBFE)
              : const Color(0xffFDBA74),
        ),
      ),
      child: Text(
        hasEditableSession
            ? 'يمكن تعديل كل يوم مستقبلي بشكل مستقل حتى يبدأ العامل التنقل أو التنفيذ. قبول عامل لا يجمّد بقية أيام المناسبة.'
            : 'لا يوجد يوم مستقبلي قابل لتعديل الموعد حالياً. الأيام المكتملة أو التي بدأ تنفيذها تبقى محفوظة كما هي.',
        style: TextStyle(
          color: hasEditableSession
              ? const Color(0xff1E3A8A)
              : const Color(0xff9A3412),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'لا توجد أيام تنفيذ مسجلة لهذه المناسبة.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
