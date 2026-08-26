import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          _error = 'هذا الطلب لا يحتوي جدول مناسبة متعدد الأيام.';
        });
        return;
      }
      final activeSessions = schedule.sessions
          .where((session) => !session.isCompleted && !session.isCancelled)
          .toList(growable: false);
      final canReschedule = activeSessions.isNotEmpty &&
          activeSessions.every((session) => session.canReschedule);
      setState(() {
        _sessions
          ..clear()
          ..addAll(
            schedule.sessions
                .where((session) => !session.isCancelled)
                .map(
                  (session) => _DraftSession(
                    id: session.id,
                    date: session.date ?? DateTime.now().add(const Duration(days: 1)),
                    time: session.time ?? '09:00',
                    hours: session.hours > 0 ? session.hours : 1,
                    locked: session.isCompleted,
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

  void _sort() {
    _sessions.sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      return a.time.compareTo(b.time);
    });
  }

  String _dateApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  Future<void> _pickDate(int index) async {
    if (!_editAllowed || _sessions[index].locked) return;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final first = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final initial = _sessions[index].date.isBefore(first) ? first : _sessions[index].date;
    final selected = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
      initialDate: initial,
    );
    if (selected == null) return;
    final duplicate = _sessions.asMap().entries.any(
      (entry) => entry.key != index && _sameDay(entry.value.date, selected),
    );
    if (duplicate) {
      _showMessage('هذا اليوم موجود بالفعل في جدول المناسبة.');
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
    final selected = await showTimePicker(context: context, initialTime: initial);
    if (selected == null) return;
    setState(() {
      _sessions[index].time =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _editHours(int index) async {
    if (!_editAllowed || _sessions[index].locked) return;
    final controller = TextEditingController(text: _hours(_sessions[index].hours));
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('مدة هذا اليوم'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
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
                  if (parsed == null || parsed <= 0 || parsed > 24) {
                    setDialogState(() {
                      error = 'يجب أن تكون المدة أكبر من 0 وحتى 24 ساعة';
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
    controller.dispose();
    if (value == null) return;
    setState(() => _sessions[index].hours = value);
  }

  Future<void> _addDay() async {
    if (!_editAllowed || _sessions.length >= 31) return;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final first = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final selected = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
      initialDate: _sessions.isEmpty
          ? first
          : _sessions.last.date.add(const Duration(days: 1)),
    );
    if (selected == null) return;
    if (_sessions.any((session) => _sameDay(session.date, selected))) {
      _showMessage('هذا اليوم موجود بالفعل في جدول المناسبة.');
      return;
    }
    final template = _sessions.where((session) => !session.locked).isNotEmpty
        ? _sessions.where((session) => !session.locked).first
        : (_sessions.isEmpty ? null : _sessions.first);
    setState(() {
      _sessions.add(
        _DraftSession(
          date: selected,
          time: template?.time ?? '09:00',
          hours: template?.hours ?? 4,
          locked: false,
        ),
      );
      _sort();
    });
  }

  void _remove(int index) {
    if (!_editAllowed || _sessions[index].locked) return;
    final editableCount = _sessions.where((session) => !session.locked).length;
    if (editableCount <= 1 && _sessions.where((session) => session.locked).isEmpty) {
      _showMessage('يجب أن يبقى يوم واحد على الأقل.');
      return;
    }
    setState(() => _sessions.removeAt(index));
  }

  void _applyFirstEditableToAll() {
    if (!_editAllowed) return;
    final editable = _sessions.where((session) => !session.locked).toList();
    if (editable.length < 2) return;
    final source = editable.first;
    setState(() {
      for (final session in _sessions) {
        if (session.locked) continue;
        session
          ..time = source.time
          ..hours = source.hours;
      }
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _save() async {
    if (!_editAllowed || _saving) return;
    final active = _sessions.where((session) => !session.locked).toList();
    if (active.isEmpty) {
      _showMessage('لا يوجد جدول مستقبلي قابل للتعديل.');
      return;
    }
    if (_sessions.length > 31) {
      _showMessage('الحد الأعلى هو 31 يوماً.');
      return;
    }
    final seen = <String>{};
    for (final session in _sessions) {
      final key = _dateApi(session.date);
      if (!seen.add(key)) {
        _showMessage('لا يمكن تكرار اليوم نفسه.');
        return;
      }
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(session.time) ||
          session.hours <= 0 ||
          session.hours > 24) {
        _showMessage('تحقق من الوقت والمدة لكل يوم.');
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
            'تعذر تعديل أيام المناسبة. إذا كان أحد العمال قد قبل الطلب، فلن يسمح النظام بتغيير الجدول ويمكنك إلغاء الأيام المستقبلية حسب السياسة.';
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(title: const Text('تعديل أيام المناسبة')),
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
                          'لا يمكن تعديل أيام المناسبة بعد قبول العامل للطلب. يمكنك إلغاء الأيام القادمة حسب سياسة الإلغاء.',
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
                              '${_sessions.length} أيام في الجدول',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _editAllowed ? _addDay : null,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة يوم'),
                          ),
                        ],
                      ),
                    ),
                    if (_sessions.where((session) => !session.locked).length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: _editAllowed ? _applyFirstEditableToAll : null,
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('تطبيق نفس الوقت والمدة على الأيام المستقبلية'),
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                                            ? 'يوم مكتمل - محفوظ في السجل'
                                            : 'يوم ${index + 1}',
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
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.calendar_today_outlined),
                                  title: const Text('التاريخ'),
                                  trailing: Text(_dateLabel(session.date)),
                                  onTap: session.locked ? null : () => _pickDate(index),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.schedule),
                                  title: const Text('وقت البدء'),
                                  trailing: Text(session.time),
                                  onTap: session.locked ? null : () => _pickTime(index),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.timelapse),
                                  title: const Text('المدة'),
                                  trailing: Text('${_hours(session.hours)} ساعة'),
                                  onTap: session.locked ? null : () => _editHours(index),
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
                        padding: const EdgeInsets.all(16),
                        child: FilledButton(
                          onPressed: _editAllowed && !_saving ? _save : null,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('حفظ جدول المناسبة'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _DraftSession {
  _DraftSession({
    this.id,
    required this.date,
    required this.time,
    required this.hours,
    required this.locked,
  });

  final int? id;
  DateTime date;
  String time;
  double hours;
  final bool locked;
}
