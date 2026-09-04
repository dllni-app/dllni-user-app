from pathlib import Path


def replace_once(path: str, old: str, new: str, label: str) -> None:
    p = Path(path)
    text = p.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected 1 match, found {count}")
    p.write_text(text.replace(old, new, 1))


# Revision preview response model.
replace_once(
    "lib/features/orders/data/models/cleaning_booking_schedule_model.dart",
    "class CleaningMultiDayOrderEnvelope {\n",
    """class CleaningRecurringScheduleRevisionPreviewModel {
  final String revisionToken;
  final bool requiresReconfirmation;
  final bool scheduleChanged;
  final bool priceChanged;
  final double oldTotal;
  final double newTotal;
  final double priceDelta;
  final double discountAmount;
  final String currency;
  final int editableSessionsCount;
  final int preservedSessionsCount;
  final int proposedSessionsCount;
  final double sessionHours;

  const CleaningRecurringScheduleRevisionPreviewModel({
    required this.revisionToken,
    required this.requiresReconfirmation,
    required this.scheduleChanged,
    required this.priceChanged,
    required this.oldTotal,
    required this.newTotal,
    required this.priceDelta,
    required this.discountAmount,
    required this.currency,
    required this.editableSessionsCount,
    required this.preservedSessionsCount,
    required this.proposedSessionsCount,
    required this.sessionHours,
  });

  factory CleaningRecurringScheduleRevisionPreviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningRecurringScheduleRevisionPreviewModel(
      revisionToken: _string(json['revisionToken'] ?? json['revision_token']) ?? '',
      requiresReconfirmation:
          _bool(
            json['requiresReconfirmation'] ?? json['requires_reconfirmation'],
          ) ??
          false,
      scheduleChanged:
          _bool(json['scheduleChanged'] ?? json['schedule_changed']) ?? false,
      priceChanged:
          _bool(json['priceChanged'] ?? json['price_changed']) ?? false,
      oldTotal: _double(json['oldTotal'] ?? json['old_total']) ?? 0,
      newTotal: _double(json['newTotal'] ?? json['new_total']) ?? 0,
      priceDelta: _double(json['priceDelta'] ?? json['price_delta']) ?? 0,
      discountAmount:
          _double(json['discountAmount'] ?? json['discount_amount']) ?? 0,
      currency: _string(json['currency']) ?? '',
      editableSessionsCount:
          _int(
            json['editableSessionsCount'] ?? json['editable_sessions_count'],
          ) ??
          0,
      preservedSessionsCount:
          _int(
            json['preservedSessionsCount'] ?? json['preserved_sessions_count'],
          ) ??
          0,
      proposedSessionsCount:
          _int(
            json['proposedSessionsCount'] ?? json['proposed_sessions_count'],
          ) ??
          0,
      sessionHours:
          _double(json['sessionHours'] ?? json['session_hours']) ?? 0,
    );
  }
}

CleaningRecurringScheduleRevisionPreviewModel
cleaningRecurringScheduleRevisionPreviewFromJson(dynamic json) {
  final root = json is String ? _map(jsonDecode(json)) : _map(json);
  final data = _map(root['data']);
  return CleaningRecurringScheduleRevisionPreviewModel.fromJson(
    _map(data['revision'] ?? root['revision']),
  );
}

class CleaningMultiDayOrderEnvelope {
""",
    "revision preview model insertion",
)

# Dedicated preview + confirm calls. Existing event reschedule stays untouched.
replace_once(
    "lib/features/orders/data/source/cleaning_session_remote_data_source.dart",
    "  Future<CleaningMultiDayOrderEnvelope> updateSchedule({\n",
    """  Future<CleaningRecurringScheduleRevisionPreviewModel>
  previewRecurringScheduleRevision({
    required int orderId,
    required List<Map<String, dynamic>> sessions,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/recurring-schedule/preview',
        data: <String, dynamic>{
          'schedule': <String, dynamic>{
            'mode': 'recurring',
            'sessions': sessions,
          },
        },
      ),
      jsonConvert: cleaningRecurringScheduleRevisionPreviewFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmRecurringScheduleRevision({
    required int orderId,
    required List<Map<String, dynamic>> sessions,
    required String revisionToken,
  }) {
    return _post(
      '/api/v1/user/cleaning/orders/$orderId/recurring-schedule/confirm',
      data: <String, dynamic>{
        'schedule': <String, dynamic>{
          'mode': 'recurring',
          'sessions': sessions,
        },
        'revisionToken': revisionToken,
      },
    );
  }

  Future<CleaningMultiDayOrderEnvelope> updateSchedule({
""",
    "revision datasource methods",
)

screen = r'''import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';

class RecurringCleaningScheduleRevisionScreen extends StatefulWidget {
  const RecurringCleaningScheduleRevisionScreen({
    super.key,
    required this.orderId,
    required this.initialSessions,
  });

  final int orderId;
  final List<CleaningBookingSessionModel> initialSessions;

  @override
  State<RecurringCleaningScheduleRevisionScreen> createState() =>
      _RecurringCleaningScheduleRevisionScreenState();
}

class _RecurringCleaningScheduleRevisionScreenState
    extends State<RecurringCleaningScheduleRevisionScreen> {
  final List<_RecurringDraftVisit> _visits = <_RecurringDraftVisit>[];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visits.addAll(
      widget.initialSessions
          .where(
            (session) =>
                session.sessionType == 'recurring_cleaning' &&
                !session.isTerminal &&
                !session.isPaused &&
                !session.hasStartedExecution &&
                !session.isPast &&
                session.date != null &&
                session.time != null,
          )
          .map(
            (session) => _RecurringDraftVisit(
              date: DateTime(
                session.date!.year,
                session.date!.month,
                session.date!.day,
              ),
              time: session.time!,
            ),
          ),
    );
    if (_visits.isEmpty) {
      _visits.add(
        _RecurringDraftVisit(
          date: DateTime(now.year, now.month, now.day).add(
            const Duration(days: 1),
          ),
          time: '09:00',
        ),
      );
    }
    _sort();
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _money(double value) => value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  void _sort() {
    _visits.sort((left, right) {
      final dateCompare = left.date.compareTo(right.date);
      return dateCompare != 0 ? dateCompare : left.time.compareTo(right.time);
    });
  }

  String _slotKey(_RecurringDraftVisit visit) =>
      '${_dateApi(visit.date)}|${visit.time}';

  bool _slotExists(DateTime date, String time, {int? except}) {
    final target = '${_dateApi(date)}|$time';
    for (var index = 0; index < _visits.length; index++) {
      if (index == except) continue;
      if (_slotKey(_visits[index]) == target) return true;
    }
    return false;
  }

  Future<void> _pickDate(int index) async {
    final firstDate = _today();
    final initial = _visits[index].date.isBefore(firstDate)
        ? firstDate
        : _visits[index].date;
    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      initialDate: initial,
    );
    if (picked == null || !mounted) return;
    if (_slotExists(picked, _visits[index].time, except: index)) {
      _message('توجد زيارة أخرى في التاريخ والوقت نفسيهما.');
      return;
    }
    setState(() {
      _visits[index].date = picked;
      _sort();
    });
  }

  Future<void> _pickTime(int index) async {
    final parts = _visits[index].time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 9,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (picked == null || !mounted) return;
    final time =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    if (_slotExists(_visits[index].date, time, except: index)) {
      _message('لا يمكن تكرار التاريخ والوقت نفسيهما.');
      return;
    }
    setState(() {
      _visits[index].time = time;
      _sort();
    });
  }

  Future<void> _addVisit() async {
    final base = _visits.isEmpty ? _today() : _visits.last.date;
    final suggested = base.add(const Duration(days: 7));
    final firstDate = _today();
    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      initialDate: suggested.isBefore(firstDate) ? firstDate : suggested,
    );
    if (picked == null || !mounted) return;
    var time = _visits.isEmpty ? '09:00' : _visits.last.time;
    if (_slotExists(picked, time)) {
      for (var hour = 0; hour < 24; hour++) {
        final candidate = '${hour.toString().padLeft(2, '0')}:00';
        if (!_slotExists(picked, candidate)) {
          time = candidate;
          break;
        }
      }
    }
    setState(() {
      _visits.add(_RecurringDraftVisit(date: picked, time: time));
      _sort();
    });
  }

  void _removeVisit(int index) {
    if (_visits.length <= 1) {
      _message(
        'يجب أن تبقى زيارة مستقبلية واحدة على الأقل في هذا التعديل.',
      );
      return;
    }
    setState(() => _visits.removeAt(index));
  }

  String? _validate() {
    if (_visits.isEmpty) return 'أضف زيارة مستقبلية واحدة على الأقل.';
    final keys = <String>{};
    for (final visit in _visits) {
      if (!keys.add(_slotKey(visit))) {
        return 'لا يمكن تكرار التاريخ والوقت نفسيهما.';
      }
      if (visit.date.isBefore(_today())) {
        return 'كل الزيارات المعدلة يجب أن تكون في المستقبل.';
      }
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(visit.time)) {
        return 'يوجد وقت زيارة غير صالح.';
      }
    }
    final sorted = [..._visits]..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.length > 1 &&
        sorted.last.date.difference(sorted.first.date).inDays > 30) {
      return 'يجب أن تقع الزيارات المستقبلية المعدلة ضمن فترة لا تتجاوز 30 يوماً.';
    }
    return null;
  }

  List<Map<String, dynamic>> _payload() => _visits
      .map(
        (visit) => <String, dynamic>{
          'date': _dateApi(visit.date),
          'time': visit.time,
        },
      )
      .toList(growable: false);

  Future<void> _previewAndConfirm() async {
    if (_saving) return;
    final validation = _validate();
    if (validation != null) {
      _message(validation);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final dataSource = getIt<CleaningSessionRemoteDataSource>();
    final payload = _payload();
    try {
      final preview = await dataSource.previewRecurringScheduleRevision(
        orderId: widget.orderId,
        sessions: payload,
      );
      if (!mounted) return;

      if (!preview.scheduleChanged) {
        _message('لم يتغير جدول الزيارات المستقبلية.');
        setState(() => _saving = false);
        return;
      }

      final approved = await _showReconfirmation(preview);
      if (!approved || !mounted) {
        if (mounted) setState(() => _saving = false);
        return;
      }

      await dataSource.confirmRecurringScheduleRevision(
        orderId: widget.orderId,
        sessions: payload,
        revisionToken: preview.revisionToken,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            'تعذر تأكيد تعديل الزيارات. ربما تغيّرت حالة إحدى الزيارات أو الأسعار؛ حدّث الحجز وأعد المعاينة.';
      });
    }
  }

  Future<bool> _showReconfirmation(
    CleaningRecurringScheduleRevisionPreviewModel preview,
  ) async {
    final currency = preview.currency.trim();
    final unit = currency.isEmpty ? '' : ' $currency';
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('تأكيد الجدول والسعر الجديد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('الزيارات المستقبلية الجديدة: ${preview.proposedSessionsCount}'),
                if (preview.preservedSessionsCount > 0)
                  Text('الزيارات المحفوظة من السجل: ${preview.preservedSessionsCount}'),
                const SizedBox(height: 12),
                Text('الإجمالي الحالي: ${_money(preview.oldTotal)}$unit'),
                Text(
                  'الإجمالي بعد التعديل: ${_money(preview.newTotal)}$unit',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (preview.priceChanged)
                  Text(
                    'فرق السعر: ${preview.priceDelta >= 0 ? '+' : ''}${_money(preview.priceDelta)}$unit',
                  ),
                const SizedBox(height: 10),
                const Text(
                  'عند التأكيد سيتم تحرير العمال المرتبطين بالزيارات المستقبلية المستبدلة وإعادة فتح الزيارات الجديدة للبحث عن عمال. الزيارات المنفذة أو التاريخية لن تتغير.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأكيد التعديل والسعر'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('تعديل الزيارات الدورية القادمة')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Text(
                    'هذا التعديل يخص الزيارات المستقبلية القابلة للتعديل فقط. سيعيد السيرفر التسعير أولاً، ولن يُطبّق أي تغيير قبل أن تؤكد السعر والجدول المعروضين.',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                ...List.generate(_visits.length, (index) {
                  final visit = _visits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الزيارة ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _saving
                                          ? null
                                          : () => _pickDate(index),
                                      icon: const Icon(Icons.calendar_month_outlined),
                                      label: Text(_dateLabel(visit.date)),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _saving
                                          ? null
                                          : () => _pickTime(index),
                                      icon: const Icon(Icons.schedule_outlined),
                                      label: Text(visit.time),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'حذف الزيارة',
                            onPressed: _saving ? null : () => _removeVisit(index),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _addVisit,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة زيارة مستقبلية'),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _previewAndConfirm,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.price_check_rounded),
                  label: Text(
                    _saving ? 'جارٍ التحقق من السعر...' : 'معاينة السعر والتأكيد',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringDraftVisit {
  _RecurringDraftVisit({required this.date, required this.time});

  DateTime date;
  String time;
}
'''
Path("lib/features/orders/view/screens/recurring_cleaning_schedule_revision_screen.dart").write_text(screen)

# Link the recurring series card to the dedicated editor.
replace_once(
    "lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart",
    "import 'multi_day_cleaning_order_reschedule_screen.dart';\n",
    "import 'multi_day_cleaning_order_reschedule_screen.dart';\nimport 'recurring_cleaning_schedule_revision_screen.dart';\n",
    "revision screen import",
)
replace_once(
    "lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart",
    "  Future<void> _confirmStartVerification(\n",
    """  Future<void> _openRecurringRevision() async {
    final schedule = _schedule;
    if (!widget.recurring || schedule == null || schedule.isPaused) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecurringCleaningScheduleRevisionScreen(
          orderId: widget.orderId,
          initialSessions: schedule.sessions,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _confirmStartVerification(
""",
    "open recurring revision action",
)
replace_once(
    "lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart",
    "        if (schedule.canResume) ...[\n",
    """        if (!paused) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy || _busySessionId != null
                ? null
                : _openRecurringRevision,
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('تعديل الزيارات القادمة'),
          ),
        ],
        if (schedule.canResume) ...[
""",
    "revision button in series card",
)

model_test = r'''import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses recurring schedule revision price reconfirmation preview', () {
    final preview = cleaningRecurringScheduleRevisionPreviewFromJson({
      'success': true,
      'data': {
        'revision': {
          'revisionToken': 'a' * 64,
          'requiresReconfirmation': true,
          'scheduleChanged': true,
          'priceChanged': true,
          'oldTotal': 300,
          'newTotal': 400,
          'priceDelta': 100,
          'discountAmount': 25,
          'currency': 'SYP',
          'editableSessionsCount': 3,
          'preservedSessionsCount': 1,
          'proposedSessionsCount': 4,
          'sessionHours': 2.5,
        },
      },
    });

    expect(preview.revisionToken, hasLength(64));
    expect(preview.requiresReconfirmation, isTrue);
    expect(preview.scheduleChanged, isTrue);
    expect(preview.priceChanged, isTrue);
    expect(preview.oldTotal, 300);
    expect(preview.newTotal, 400);
    expect(preview.priceDelta, 100);
    expect(preview.discountAmount, 25);
    expect(preview.currency, 'SYP');
    expect(preview.editableSessionsCount, 3);
    expect(preview.preservedSessionsCount, 1);
    expect(preview.proposedSessionsCount, 4);
    expect(preview.sessionHours, 2.5);
  });
}
'''
Path("test/features/orders/data/models/cleaning_recurring_schedule_revision_model_test.dart").write_text(model_test)
