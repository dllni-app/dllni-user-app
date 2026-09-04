import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<_DraftSession> _sessions = <_DraftSession>[];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _editAllowed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await getIt<CleaningSessionRemoteDataSource>()
          .fetchBookingSchedule(widget.orderId);
      final schedule = result.schedule;
      if (!mounted) return;

      if (schedule == null || !schedule.isMultiDay) {
        setState(() {
          _loading = false;
          _error = 'هذا الطلب لا يحتوي جدول مناسبة متعدد الجلسات.';
        });
        return;
      }

      final nonCancelled = schedule.sessions
          .where((session) => !session.isCancelled)
          .toList(growable: false);
      final parentStatus = (result.status ?? '').trim().toLowerCase();
      final parentStillEditable =
          parentStatus.isEmpty || parentStatus == 'pending';
      final executionNotStarted = nonCancelled.every(
        (session) => !session.hasStartedExecution && !session.isCompleted,
      );
      final backendDidNotForbid = nonCancelled.every(
        (session) => session.canReschedule != false,
      );
      final canReschedule =
          nonCancelled.isNotEmpty &&
          parentStillEditable &&
          executionNotStarted &&
          backendDidNotForbid;

      setState(() {
        _sessions
          ..clear()
          ..addAll(
            nonCancelled.map(
              (session) => _DraftSession(
                id: session.id,
                date: session.date ?? _today(),
                time: session.time ?? '09:00',
                hours: session.hours >= 1 ? session.hours : 1,
                locked: !canReschedule,
              ),
            ),
          );
        _sort();
        _editAllowed = canReschedule;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل جدول المناسبة.';
      });
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _sort() {
    _sessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });
  }

  String _dateApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _slotKey(DateTime date, String time) => '${_dateApi(date)}|$time';

  bool _hasDuplicateSlot({
    required DateTime date,
    required String time,
    int? exceptIndex,
  }) {
    final key = _slotKey(date, time);
    for (var index = 0; index < _sessions.length; index++) {
      if (exceptIndex == index) continue;
      final session = _sessions[index];
      if (_slotKey(session.date, session.time) == key) return true;
    }
    return false;
  }

  String _nextAvailableTime(
    DateTime date,
    String preferred, {
    int? exceptIndex,
  }) {
    if (!_hasDuplicateSlot(
      date: date,
      time: preferred,
      exceptIndex: exceptIndex,
    )) {
      return preferred;
    }
    final parts = preferred.split(':');
    final startHour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    for (var step = 1; step < 24; step++) {
      final hour = (startHour + step) % 24;
      final candidate =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      if (!_hasDuplicateSlot(
        date: date,
        time: candidate,
        exceptIndex: exceptIndex,
      )) {
        return candidate;
      }
    }
    return preferred;
  }

  Future<void> _pickDate(int index) async {
    if (!_editAllowed || _sessions[index].locked) return;
    final first = _today();
    final initial = _sessions[index].date.isBefore(first)
        ? first
        : _sessions[index].date;
    final selected = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
      initialDate: initial,
    );
    if (selected == null) return;

    final session = _sessions[index];
    if (_hasDuplicateSlot(
      date: selected,
      time: session.time,
      exceptIndex: index,
    )) {
      _showMessage(
        'توجد جلسة أخرى في التاريخ والوقت نفسيهما. اختر وقتاً مختلفاً.',
      );
      return;
    }

    setState(() {
      _sessions[index].date = selected;
      _sort();
    });
  }

  Future<void> _pickTime(int index) async {
    if (!_editAllowed || _sessions[index].locked) return;
    final parts = _sessions[index].time.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;
    final time =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';

    if (_hasDuplicateSlot(
      date: _sessions[index].date,
      time: time,
      exceptIndex: index,
    )) {
      _showMessage('لا يمكن تكرار التاريخ والوقت نفسيهما لجلسة أخرى.');
      return;
    }

    setState(() {
      _sessions[index].time = time;
      _sort();
    });
  }

  Future<void> _editHours(int index) async {
    if (!_editAllowed || _sessions[index].locked) return;
    final controller = TextEditingController(
      text: _hours(_sessions[index].hours),
    );
    try {
      final value = await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('مدة هذه الجلسة'),
              content: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,2}(\.\d{0,2})?'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'الساعات',
                  errorText: error,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text.trim());
                    if (parsed == null || parsed < 1 || parsed > 24) {
                      setDialogState(() {
                        error = 'يجب أن تكون المدة بين 1 و24 ساعة';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(parsed);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      );
      if (!mounted || value == null) return;
      setState(() => _sessions[index].hours = value);
    } finally {
      controller.dispose();
    }
  }

  Future<void> _addSession() async {
    if (!_editAllowed) return;
    final first = _today();
    final suggestedDate = _sessions.isEmpty ? first : _sessions.last.date;
    final initialDate = suggestedDate.isBefore(first) ? first : suggestedDate;
    final selected = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
      initialDate: initialDate,
    );
    if (selected == null) return;

    final template = _sessions.isEmpty ? null : _sessions.first;
    final preferredTime = template?.time ?? '09:00';
    final time = _nextAvailableTime(selected, preferredTime);
    if (_hasDuplicateSlot(date: selected, time: time)) {
      _showMessage(
        'لا يوجد وقت افتراضي متاح لهذا التاريخ. عدّل وقت جلسة أخرى أولاً.',
      );
      return;
    }

    setState(() {
      _sessions.add(
        _DraftSession(
          date: selected,
          time: time,
          hours: template?.hours ?? 4,
          locked: false,
        ),
      );
      _sort();
    });
  }

  void _remove(int index) {
    if (!_editAllowed || _sessions[index].locked) return;
    if (_sessions.length <= 1) {
      _showMessage('يجب أن تبقى جلسة واحدة على الأقل.');
      return;
    }
    setState(() => _sessions.removeAt(index));
  }

  void _applyFirstToAll() {
    if (!_editAllowed || _sessions.length < 2) return;
    final source = _sessions.first;
    setState(() {
      for (var index = 1; index < _sessions.length; index++) {
        final session = _sessions[index];
        session.hours = source.hours;
        session.time = _nextAvailableTime(
          session.date,
          source.time,
          exceptIndex: index,
        );
      }
      _sort();
    });
  }

  Future<void> _save() async {
    if (!_editAllowed || _saving) return;
    if (_sessions.isEmpty) {
      _showMessage('يجب أن تبقى جلسة واحدة على الأقل.');
      return;
    }
    final seen = <String>{};
    for (var index = 0; index < _sessions.length; index++) {
      final session = _sessions[index];
      final key = _slotKey(session.date, session.time);
      if (!seen.add(key)) {
        _showMessage('لا يمكن تكرار التاريخ والوقت نفسيهما.');
        return;
      }
      if (session.date.isBefore(_today())) {
        _showMessage(
          'تاريخ الجلسة ${index + 1} يجب أن يكون اليوم أو في المستقبل.',
        );
        return;
      }
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(session.time)) {
        _showMessage('وقت الجلسة ${index + 1} غير صالح.');
        return;
      }
      if (session.hours < 1 || session.hours > 24) {
        _showMessage('مدة الجلسة ${index + 1} يجب أن تكون بين 1 و24 ساعة.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final payload = _sessions
          .map(
            (session) => <String, dynamic>{
              'date': _dateApi(session.date),
              'time': session.time,
              'hours': session.hours,
            },
          )
          .toList(growable: false);
      await getIt<CleaningSessionRemoteDataSource>().updateSchedule(
        orderId: widget.orderId,
        sessions: payload,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            'تعذر تعديل الجدول. لا يسمح النظام بتغيير الجلسات بعد قبول عامل أو بعد بدء/إكمال أي جلسة.';
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(title: const Text('تعديل جلسات المناسبة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _sessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (!_editAllowed)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffFDBA74)),
                    ),
                    child: const Text(
                      'لا يمكن تعديل جدول المناسبة بعد قبول أحد العمال أو بعد بدء/إكمال جلسة. يمكنك إلغاء الجلسات المستقبلية التي يسمح النظام بإلغائها.',
                    ),
                  ),
                if (_error != null && _sessions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xffB91C1C)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_sessions.length} جلسات في الجدول',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _editAllowed && _sessions.length < 31
                            ? _addSession
                            : null,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة جلسة'),
                      ),
                    ],
                  ),
                ),
                if (_sessions.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: _editAllowed ? _applyFirstToAll : null,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('تطبيق مدة ووقت الجلسة الأولى'),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    session.locked
                                        ? 'جلسة محفوظة وغير قابلة للتعديل'
                                        : 'الجلسة ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (!session.locked && _editAllowed)
                                  IconButton(
                                    onPressed: () => _remove(index),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _editAllowed && !session.locked
                                        ? () => _pickDate(index)
                                        : null,
                                    icon: const Icon(Icons.event_outlined),
                                    label: Text(_dateLabel(session.date)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _editAllowed && !session.locked
                                        ? () => _pickTime(index)
                                        : null,
                                    icon: const Icon(Icons.schedule),
                                    label: Text(session.time),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _editAllowed && !session.locked
                                  ? () => _editHours(index)
                                  : null,
                              icon: const Icon(Icons.timelapse),
                              label: Text('${_hours(session.hours)} ساعة'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: !_editAllowed || _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('حفظ الجدول'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DraftSession {
  final int? id;
  DateTime date;
  String time;
  double hours;
  final bool locked;

  _DraftSession({
    this.id,
    required this.date,
    required this.time,
    required this.hours,
    required this.locked,
  });
}
