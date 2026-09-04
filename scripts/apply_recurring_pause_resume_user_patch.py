from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected one match, found {count}")
    return text.replace(old, new, 1)


model = Path("lib/features/orders/data/models/cleaning_booking_schedule_model.dart")
text = model.read_text()
text = replace_once(
    text,
    "  bool get isSkipped => status == 'skipped';\n  bool get isTerminal =>\n",
    "  bool get isSkipped => status == 'skipped';\n  bool get isPaused => status == 'paused';\n  bool get isTerminal =>\n",
    "session paused getter",
)
text = replace_once(
    text,
    "class CleaningBookingScheduleModel {\n  final String mode;\n  final int daysCount;\n",
    "class CleaningBookingScheduleModel {\n  final String mode;\n  final bool isRecurring;\n  final bool isPaused;\n  final bool canPause;\n  final bool canResume;\n  final String? pausedAt;\n  final String? pauseReason;\n  final int daysCount;\n",
    "schedule series fields",
)
text = replace_once(
    text,
    "  const CleaningBookingScheduleModel({\n    required this.mode,\n    required this.daysCount,\n",
    "  const CleaningBookingScheduleModel({\n    required this.mode,\n    this.isRecurring = false,\n    this.isPaused = false,\n    this.canPause = false,\n    this.canResume = false,\n    this.pausedAt,\n    this.pauseReason,\n    required this.daysCount,\n",
    "schedule series constructor",
)
text = replace_once(
    text,
    "      mode:\n          _string(json['mode']) ??\n          (sessions.length > 1 ? 'multi_day' : 'single_day'),\n      daysCount:\n",
    "      mode:\n          _string(json['mode']) ??\n          (sessions.length > 1 ? 'multi_day' : 'single_day'),\n      isRecurring:\n          _bool(json['isRecurring'] ?? json['is_recurring']) ??\n          sessions.any((item) => item.sessionType == 'recurring_cleaning'),\n      isPaused: _bool(json['isPaused'] ?? json['is_paused']) ?? false,\n      canPause: _bool(json['canPause'] ?? json['can_pause']) ?? false,\n      canResume: _bool(json['canResume'] ?? json['can_resume']) ?? false,\n      pausedAt: _string(json['pausedAt'] ?? json['paused_at']),\n      pauseReason: _string(json['pauseReason'] ?? json['pause_reason']),\n      daysCount:\n",
    "schedule series parsing",
)
text = replace_once(
    text,
    "  bool get isMultiDay => mode == 'multi_day' || sessions.length > 1;\n  bool get hasSessions => sessions.isNotEmpty;\n",
    "  bool get isMultiDay => mode == 'multi_day' || sessions.length > 1;\n  bool get hasSessions => sessions.isNotEmpty;\n  bool get hasRecurringSeriesState =>\n      isRecurring || isPaused || canPause || canResume;\n",
    "schedule recurring state getter",
)
model.write_text(text)

source = Path("lib/features/orders/data/source/cleaning_session_remote_data_source.dart")
text = source.read_text()
text = replace_once(
    text,
    "  Future<CleaningMultiDayOrderEnvelope> changeWorkers({\n",
    "  Future<CleaningMultiDayOrderEnvelope> pauseRecurringSeries({\n    required int orderId,\n    required String reason,\n  }) {\n    return _post(\n      '/api/v1/cleaning-bookings/$orderId/recurring/pause',\n      data: <String, dynamic>{'reason': reason.trim()},\n    );\n  }\n\n  Future<CleaningMultiDayOrderEnvelope> resumeRecurringSeries({\n    required int orderId,\n  }) {\n    return _post('/api/v1/cleaning-bookings/$orderId/recurring/resume');\n  }\n\n  Future<CleaningMultiDayOrderEnvelope> changeWorkers({\n",
    "recurring pause datasource",
)
source.write_text(text)

screen = Path("lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart")
text = screen.read_text()
text = replace_once(
    text,
    "  int? _busySessionId;\n  bool _submittingReview = false;\n",
    "  int? _busySessionId;\n  bool _busySeriesAction = false;\n  bool _submittingReview = false;\n",
    "series busy state",
)
text = replace_once(
    text,
    "  Future<void> _openReschedule() async {\n",
    "  Future<void> _runSeriesAction(\n    Future<CleaningMultiDayOrderEnvelope> Function() action,\n  ) async {\n    if (_busySeriesAction || _busySessionId != null) return;\n\n    setState(() {\n      _busySeriesAction = true;\n      _actionError = null;\n    });\n\n    try {\n      final envelope = await action();\n      if (!mounted) return;\n      if (envelope.schedule != null) {\n        setState(() => _envelope = envelope);\n      } else {\n        await _load();\n      }\n    } catch (_) {\n      if (!mounted) return;\n      setState(() {\n        _actionError =\n            'تعذر تحديث حالة الحجز الدوري. حدّث الطلب وتحقق من حالته ثم حاول مرة أخرى.';\n      });\n    } finally {\n      if (mounted) setState(() => _busySeriesAction = false);\n    }\n  }\n\n  Future<void> _openReschedule() async {\n",
    "series action runner",
)
text = replace_once(
    text,
    "  Future<void> _sendSos(CleaningBookingSessionModel session) async {\n",
    "  Future<void> _pauseRecurringSeries() async {\n    final schedule = _schedule;\n    if (!widget.recurring || schedule == null || !schedule.canPause) return;\n\n    final reason = await _askText(\n      title: 'إيقاف الحجز الدوري مؤقتاً',\n      hint: 'سبب الإيقاف المؤقت',\n      confirmLabel: 'متابعة',\n    );\n    if (reason == null) return;\n\n    final approved = await _confirmDialog(\n      title: 'تأكيد إيقاف الحجز الدوري',\n      message:\n          'سيتم إيقاف الزيارات المستقبلية المؤهلة مؤقتاً وتحرير العمال المرتبطين بها دون اعتبارها ملغاة أو متخطاة. يمكنك استئناف نفس الحجز لاحقاً.',\n      confirmLabel: 'إيقاف مؤقت',\n    );\n    if (!approved) return;\n\n    await _runSeriesAction(\n      () => _sessions.pauseRecurringSeries(\n        orderId: widget.orderId,\n        reason: reason,\n      ),\n    );\n  }\n\n  Future<void> _resumeRecurringSeries() async {\n    final schedule = _schedule;\n    if (!widget.recurring || schedule == null || !schedule.canResume) return;\n\n    final approved = await _confirmDialog(\n      title: 'استئناف الحجز الدوري',\n      message:\n          'ستعود الزيارات المستقبلية للبحث عن عمال. أي زيارة انتهى موعدها أثناء الإيقاف ستُعامل كزيارة متخطاة دون رسوم إلغاء.',\n      confirmLabel: 'استئناف الحجز',\n    );\n    if (!approved) return;\n\n    await _runSeriesAction(\n      () => _sessions.resumeRecurringSeries(orderId: widget.orderId),\n    );\n  }\n\n  Future<void> _sendSos(CleaningBookingSessionModel session) async {\n",
    "series pause resume actions",
)
text = replace_once(
    text,
    "        if (_envelope?.canReview == true || _envelope?.hasReview == true) ...[\n",
    "        if (widget.recurring && schedule.hasRecurringSeriesState) ...[\n          const SizedBox(height: 12),\n          _recurringSeriesCard(schedule),\n        ],\n        if (_envelope?.canReview == true || _envelope?.hasReview == true) ...[\n",
    "series management card insertion",
)
text = replace_once(
    text,
    "  Widget _eventReviewCard() {\n",
    "  Widget _recurringSeriesCard(CleaningBookingScheduleModel schedule) {\n    final paused = schedule.isPaused;\n    final busy = _busySeriesAction;\n\n    return _card(\n      children: [\n        Row(\n          children: [\n            Icon(\n              paused\n                  ? Icons.pause_circle_filled_rounded\n                  : Icons.repeat_rounded,\n            ),\n            const SizedBox(width: 8),\n            Expanded(\n              child: AppText.bodyLarge(\n                paused ? 'الحجز الدوري متوقف مؤقتاً' : 'إدارة الحجز الدوري',\n                fontWeight: FontWeight.w800,\n                textAlign: TextAlign.start,\n              ),\n            ),\n            if (busy)\n              const SizedBox(\n                width: 18,\n                height: 18,\n                child: CircularProgressIndicator(strokeWidth: 2),\n              ),\n          ],\n        ),\n        const SizedBox(height: 8),\n        AppText.bodySmall(\n          paused\n              ? 'الزيارات المستقبلية المتوقفة لا تُعرض للعمال حتى تستأنف هذا الحجز.'\n              : 'يمكنك إيقاف الزيارات المستقبلية مؤقتاً دون إلغاء الحجز أو حذف الزيارات.',\n          color: const Color(0xFF6B7280),\n          fontWeight: FontWeight.w600,\n          textAlign: TextAlign.start,\n        ),\n        if (schedule.pauseReason != null &&\n            schedule.pauseReason!.trim().isNotEmpty) ...[\n          const SizedBox(height: 8),\n          _infoRow('سبب الإيقاف', schedule.pauseReason!.trim()),\n        ],\n        if (schedule.canResume) ...[\n          const SizedBox(height: 12),\n          FilledButton.icon(\n            onPressed: busy || _busySessionId != null\n                ? null\n                : _resumeRecurringSeries,\n            icon: const Icon(Icons.play_circle_outline_rounded),\n            label: const Text('استئناف الحجز الدوري'),\n          ),\n        ] else if (schedule.canPause) ...[\n          const SizedBox(height: 12),\n          OutlinedButton.icon(\n            onPressed: busy || _busySessionId != null\n                ? null\n                : _pauseRecurringSeries,\n            icon: const Icon(Icons.pause_circle_outline_rounded),\n            label: const Text('إيقاف الحجز مؤقتاً'),\n          ),\n        ],\n      ],\n    );\n  }\n\n  Widget _eventReviewCard() {\n",
    "series management card",
)
screen.write_text(text)

test = Path("test/features/orders/data/models/cleaning_recurring_schedule_model_test.dart")
text = test.read_text()
insert = r'''

  test('recurring schedule preserves server pause and resume capabilities', () {
    final schedule = CleaningBookingScheduleModel.fromJson({
      'mode': 'multi_day',
      'isRecurring': true,
      'isPaused': true,
      'canPause': false,
      'canResume': true,
      'pausedAt': '2026-09-10T08:00:00+03:00',
      'pauseReason': 'سفر لمدة أسبوع',
      'sessions': [
        {
          'id': 101,
          'sequence': 1,
          'sessionType': 'recurring_cleaning',
          'date': '2026-09-12',
          'time': '09:00',
          'hours': 2,
          'status': 'paused',
          'canSkip': false,
        },
      ],
    });

    expect(schedule.isRecurring, isTrue);
    expect(schedule.isPaused, isTrue);
    expect(schedule.canPause, isFalse);
    expect(schedule.canResume, isTrue);
    expect(schedule.pausedAt, '2026-09-10T08:00:00+03:00');
    expect(schedule.pauseReason, 'سفر لمدة أسبوع');
    expect(schedule.hasRecurringSeriesState, isTrue);
    expect(schedule.sessions.single.isPaused, isTrue);
    expect(schedule.sessions.single.isTerminal, isFalse);
    expect(schedule.remainingDaysCount, 1);
    expect(schedule.totalHours, 2);
  });
'''
marker = "\n}\n"
index = text.rfind(marker)
if index == -1:
    raise SystemExit("recurring model test closing marker not found")
text = text[:index] + insert + text[index:]
test.write_text(text)
