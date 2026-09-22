from pathlib import Path


def replace(path: str, old: str, new: str) -> None:
    target = Path(path)
    text = target.read_text(encoding='utf-8')
    if new in text:
        return
    if old not in text:
        raise SystemExit(f'pattern not found in {path}: {old[:140]!r}')
    target.write_text(text.replace(old, new, 1), encoding='utf-8')


model = 'lib/features/orders/data/models/cleaning_booking_schedule_model.dart'
replace(
    model,
    "class CleaningSessionWorkerAssignmentModel {",
    "class CleaningSessionAttendanceIncidentModel {\n  final int? workerId;\n  final String? workerName;\n  final String? lateReportedAt;\n  final String? noTravelReportedAt;\n  final String? action;\n  final String? resolvedAt;\n  final String? note;\n\n  const CleaningSessionAttendanceIncidentModel({\n    this.workerId,\n    this.workerName,\n    this.lateReportedAt,\n    this.noTravelReportedAt,\n    this.action,\n    this.resolvedAt,\n    this.note,\n  });\n\n  factory CleaningSessionAttendanceIncidentModel.fromJson(\n    Map<String, dynamic> json,\n  ) {\n    return CleaningSessionAttendanceIncidentModel(\n      workerId: _int(json['workerId'] ?? json['worker_id']),\n      workerName: _string(json['workerName'] ?? json['worker_name']),\n      lateReportedAt: _string(\n        json['lateReportedAt'] ?? json['late_reported_at'],\n      ),\n      noTravelReportedAt: _string(\n        json['noTravelReportedAt'] ?? json['no_travel_reported_at'],\n      ),\n      action: _string(json['action']),\n      resolvedAt: _string(json['resolvedAt'] ?? json['resolved_at']),\n      note: _string(json['note']),\n    );\n  }\n\n  bool get isNoTravel => noTravelReportedAt != null;\n  bool get isResolved => resolvedAt != null;\n}\n\nclass CleaningSessionAttendanceModel {\n  final int lateGraceMinutes;\n  final int noTravelGraceMinutes;\n  final int minutesPastStart;\n  final List<CleaningSessionAttendanceIncidentModel> incidents;\n\n  const CleaningSessionAttendanceModel({\n    this.lateGraceMinutes = 15,\n    this.noTravelGraceMinutes = 30,\n    this.minutesPastStart = 0,\n    this.incidents = const <CleaningSessionAttendanceIncidentModel>[],\n  });\n\n  factory CleaningSessionAttendanceModel.fromJson(Map<String, dynamic> json) {\n    final rawIncidents = json['incidents'];\n    return CleaningSessionAttendanceModel(\n      lateGraceMinutes:\n          _int(json['lateGraceMinutes'] ?? json['late_grace_minutes']) ?? 15,\n      noTravelGraceMinutes:\n          _int(json['noTravelGraceMinutes'] ?? json['no_travel_grace_minutes']) ??\n          30,\n      minutesPastStart:\n          _int(json['minutesPastStart'] ?? json['minutes_past_start']) ?? 0,\n      incidents: rawIncidents is List\n          ? rawIncidents\n                .whereType<Map>()\n                .map(\n                  (item) => CleaningSessionAttendanceIncidentModel.fromJson(\n                    _map(item),\n                  ),\n                )\n                .toList(growable: false)\n          : const <CleaningSessionAttendanceIncidentModel>[],\n    );\n  }\n}\n\nclass CleaningSessionWorkerAssignmentModel {",
)
replace(
    model,
    "  final String? status;\n  final String? startedTravelAt;",
    "  final String? status;\n  final String? lateReportedAt;\n  final String? noTravelReportedAt;\n  final String? attendanceAction;\n  final String? attendanceResolvedAt;\n  final String? attendanceNote;\n  final String? startedTravelAt;",
)
replace(
    model,
    "    this.status,\n    this.startedTravelAt,",
    "    this.status,\n    this.lateReportedAt,\n    this.noTravelReportedAt,\n    this.attendanceAction,\n    this.attendanceResolvedAt,\n    this.attendanceNote,\n    this.startedTravelAt,",
)
replace(
    model,
    "      status: _string(json['status']),\n      startedTravelAt: _string(",
    "      status: _string(json['status']),\n      lateReportedAt: _string(\n        json['lateReportedAt'] ?? json['late_reported_at'],\n      ),\n      noTravelReportedAt: _string(\n        json['noTravelReportedAt'] ?? json['no_travel_reported_at'],\n      ),\n      attendanceAction: _string(\n        json['attendanceAction'] ?? json['attendance_action'],\n      ),\n      attendanceResolvedAt: _string(\n        json['attendanceResolvedAt'] ?? json['attendance_resolved_at'],\n      ),\n      attendanceNote: _string(\n        json['attendanceNote'] ?? json['attendance_note'],\n      ),\n      startedTravelAt: _string(",
)
replace(
    model,
    "  final bool canSkip;\n  final bool? canReschedule;",
    "  final bool canSkip;\n  final bool canReportLate;\n  final bool canReportNoTravel;\n  final List<int> lateWorkerIds;\n  final List<int> noTravelWorkerIds;\n  final List<int> reportableLateWorkerIds;\n  final List<int> reportableNoTravelWorkerIds;\n  final CleaningSessionAttendanceModel? attendance;\n  final bool? canReschedule;",
)
replace(
    model,
    "    this.canSkip = false,\n    this.canReschedule,",
    "    this.canSkip = false,\n    this.canReportLate = false,\n    this.canReportNoTravel = false,\n    this.lateWorkerIds = const <int>[],\n    this.noTravelWorkerIds = const <int>[],\n    this.reportableLateWorkerIds = const <int>[],\n    this.reportableNoTravelWorkerIds = const <int>[],\n    this.attendance,\n    this.canReschedule,",
)
replace(
    model,
    "    final rawReviewableWorkerIds =\n        json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'];\n\n    return CleaningBookingSessionModel(",
    "    final rawReviewableWorkerIds =\n        json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'];\n    final rawLateWorkerIds = json['lateWorkerIds'] ?? json['late_worker_ids'];\n    final rawNoTravelWorkerIds =\n        json['noTravelWorkerIds'] ?? json['no_travel_worker_ids'];\n    final rawReportableLateWorkerIds =\n        json['reportableLateWorkerIds'] ?? json['reportable_late_worker_ids'];\n    final rawReportableNoTravelWorkerIds =\n        json['reportableNoTravelWorkerIds'] ??\n        json['reportable_no_travel_worker_ids'];\n\n    return CleaningBookingSessionModel(",
)
replace(
    model,
    "      canSkip: _bool(json['canSkip'] ?? json['can_skip']) ?? false,\n      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),",
    "      canSkip: _bool(json['canSkip'] ?? json['can_skip']) ?? false,\n      canReportLate:\n          _bool(json['canReportLate'] ?? json['can_report_late']) ?? false,\n      canReportNoTravel:\n          _bool(json['canReportNoTravel'] ?? json['can_report_no_travel']) ??\n          false,\n      lateWorkerIds: rawLateWorkerIds is List\n          ? rawLateWorkerIds.map(_int).whereType<int>().toList(growable: false)\n          : const <int>[],\n      noTravelWorkerIds: rawNoTravelWorkerIds is List\n          ? rawNoTravelWorkerIds\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      reportableLateWorkerIds: rawReportableLateWorkerIds is List\n          ? rawReportableLateWorkerIds\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      reportableNoTravelWorkerIds: rawReportableNoTravelWorkerIds is List\n          ? rawReportableNoTravelWorkerIds\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      attendance: json['attendance'] is Map\n          ? CleaningSessionAttendanceModel.fromJson(_map(json['attendance']))\n          : null,\n      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),",
)

source = 'lib/features/orders/data/source/cleaning_session_remote_data_source.dart'
replace(
    source,
    "  Future<CleaningMultiDayOrderEnvelope> submitSessionReview({",
    "  Future<CleaningMultiDayOrderEnvelope> reportSessionAttendance({\n    required int orderId,\n    required int sessionId,\n    required List<int> workerIds,\n    required String action,\n    String? note,\n  }) {\n    final data = <String, dynamic>{\n      'workerIds': workerIds,\n      'action': action,\n    };\n    final normalizedNote = note?.trim();\n    if (normalizedNote != null && normalizedNote.isNotEmpty) {\n      data['note'] = normalizedNote;\n    }\n\n    return _post(\n      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/attendance',\n      data: data,\n    );\n  }\n\n  Future<CleaningMultiDayOrderEnvelope> submitSessionReview({",
)

screen = 'lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart'
replace(
    screen,
    "  Future<void> _reviewRecurringSession(\n    CleaningBookingSessionModel session,\n  ) async {",
    "  Future<void> _reportRecurringLate(\n    CleaningBookingSessionModel session,\n  ) async {\n    final sessionId = session.id;\n    final workerIds = session.reportableLateWorkerIds;\n    if (!widget.recurring ||\n        sessionId == null ||\n        !session.canReportLate ||\n        workerIds.isEmpty ||\n        _busySessionId != null) {\n      return;\n    }\n\n    final names = _workerNamesForIds(session, workerIds);\n    final approved = await _confirmDialog(\n      title: 'العامل متأخر عن موعد الزيارة',\n      message:\n          'مرّت مهلة التأخير${names.isEmpty ? '' : ' للعامل: ${names.join('، ')}'}. إذا اخترت الانتظار، سنسجل البلاغ وتبقى الزيارة فعالة. إذا لم يبدأ العامل التنقل بعد مهلة عدم التنقل سيظهر لك خيار الاستبدال أو الإلغاء دون رسوم.',\n      confirmLabel: 'سأنتظر العامل',\n    );\n    if (!approved) return;\n\n    await _runSessionAction(\n      session,\n      () => _sessions.reportSessionAttendance(\n        orderId: widget.orderId,\n        sessionId: sessionId,\n        workerIds: workerIds,\n        action: 'wait',\n      ),\n    );\n  }\n\n  Future<void> _handleRecurringNoTravel(\n    CleaningBookingSessionModel session,\n  ) async {\n    final sessionId = session.id;\n    final workerIds = session.reportableNoTravelWorkerIds;\n    if (!widget.recurring ||\n        sessionId == null ||\n        !session.canReportNoTravel ||\n        workerIds.isEmpty ||\n        _busySessionId != null) {\n      return;\n    }\n\n    final names = _workerNamesForIds(session, workerIds);\n    final action = await showDialog<String>(\n      context: context,\n      builder: (dialogContext) => AlertDialog(\n        title: const Text('العامل لم يبدأ التنقل'),\n        content: Text(\n          '${names.isEmpty ? 'العامل المعيّن' : names.join('، ')} لم يبدأ التنقل بعد انتهاء المهلة المحددة. يمكنك طلب بديل لهذه الزيارة أو إلغاء الزيارة دون رسوم إلغاء.',\n        ),\n        actions: [\n          TextButton(\n            onPressed: () => Navigator.of(dialogContext).pop(),\n            child: const Text('رجوع'),\n          ),\n          TextButton(\n            onPressed: () => Navigator.of(dialogContext).pop('cancel'),\n            child: const Text('إلغاء الزيارة دون رسوم'),\n          ),\n          FilledButton(\n            onPressed: () => Navigator.of(dialogContext).pop('replace'),\n            child: const Text('استبدال العامل'),\n          ),\n        ],\n      ),\n    );\n    if (!mounted || action == null) return;\n\n    await _runSessionAction(\n      session,\n      () => _sessions.reportSessionAttendance(\n        orderId: widget.orderId,\n        sessionId: sessionId,\n        workerIds: workerIds,\n        action: action,\n      ),\n    );\n  }\n\n  List<String> _workerNamesForIds(\n    CleaningBookingSessionModel session,\n    List<int> workerIds,\n  ) {\n    final ids = workerIds.toSet();\n    return session.workerAssignments\n        .where((assignment) => assignment.workerId != null && ids.contains(assignment.workerId))\n        .map((assignment) => assignment.workerName?.trim())\n        .whereType<String>()\n        .where((name) => name.isNotEmpty)\n        .toSet()\n        .toList(growable: false);\n  }\n\n  Future<void> _reviewRecurringSession(\n    CleaningBookingSessionModel session,\n  ) async {",
)
replace(
    screen,
    "          if (widget.recurring && session.hasOpenDispute) ...[",
    "          if (widget.recurring &&\n              session.attendance != null &&\n              session.attendance!.incidents.isNotEmpty) ...[\n            const SizedBox(height: 10),\n            _attendanceIncidentPanel(session),\n          ],\n          if (widget.recurring && session.hasOpenDispute) ...[",
)
replace(
    screen,
    "        session.canSendSos ||\n        (widget.recurring && (session.canReview || session.canOpenDispute));",
    "        session.canSendSos ||\n        (widget.recurring &&\n            (session.canReportLate ||\n                session.canReportNoTravel ||\n                session.canReview ||\n                session.canOpenDispute));",
)
replace(
    screen,
    "        if (widget.recurring &&\n            (session.canReview || session.canOpenDispute)) ...[",
    "        if (widget.recurring &&\n            (session.canReportLate || session.canReportNoTravel)) ...[\n          if (session.canConfirmStartVerification ||\n              session.canConfirmCompletion ||\n              session.canSkip)\n            const SizedBox(height: 8),\n          if (session.canReportNoTravel)\n            FilledButton.icon(\n              onPressed: busy ? null : () => _handleRecurringNoTravel(session),\n              icon: const Icon(Icons.no_transfer_rounded),\n              label: const Text('العامل لم يبدأ التنقل'),\n            )\n          else if (session.canReportLate)\n            OutlinedButton.icon(\n              onPressed: busy ? null : () => _reportRecurringLate(session),\n              icon: const Icon(Icons.schedule_rounded),\n              label: const Text('الإبلاغ عن تأخر العامل'),\n            ),\n        ],\n        if (widget.recurring &&\n            (session.canReview || session.canOpenDispute)) ...[",
)
replace(
    screen,
    "  Widget _card({required List<Widget> children}) {",
    "  Widget _attendanceIncidentPanel(CleaningBookingSessionModel session) {\n    final incidents = session.attendance?.incidents ??\n        const <CleaningSessionAttendanceIncidentModel>[];\n    return Container(\n      padding: const EdgeInsets.all(10),\n      decoration: BoxDecoration(\n        color: const Color(0xFFFFFBEB),\n        borderRadius: BorderRadius.circular(12),\n        border: Border.all(color: const Color(0xFFFDE68A)),\n      ),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.stretch,\n        children: [\n          AppText.bodySmall(\n            'بلاغات التأخر وعدم التنقل',\n            fontWeight: FontWeight.w800,\n            color: const Color(0xFF92400E),\n            textAlign: TextAlign.start,\n          ),\n          const SizedBox(height: 6),\n          ...incidents.map((incident) {\n            final worker = incident.workerName?.trim().isNotEmpty == true\n                ? incident.workerName!.trim()\n                : 'العامل #${incident.workerId ?? '-'}';\n            final issue = incident.isNoTravel\n                ? 'لم يبدأ التنقل'\n                : 'تم الإبلاغ عن تأخره';\n            final action = switch (incident.action) {\n              'wait' => 'انتظار العامل',\n              'replace' => 'طلب استبدال',\n              'cancel' => 'إلغاء الزيارة دون رسوم',\n              _ => 'بانتظار الإجراء',\n            };\n            final state = incident.isResolved ? 'مغلقة' : 'مفتوحة';\n            return Padding(\n              padding: const EdgeInsets.only(bottom: 4),\n              child: AppText.bodySmall(\n                '$worker: $issue • $action • $state',\n                color: const Color(0xFF78350F),\n                fontWeight: FontWeight.w600,\n                textAlign: TextAlign.start,\n              ),\n            );\n          }),\n        ],\n      ),\n    );\n  }\n\n  Widget _card({required List<Widget> children}) {",
)

# Add a focused parser regression before the main test group's final brace.
test_path = Path('test/features/orders/data/models/cleaning_booking_schedule_model_test.dart')
test_text = test_path.read_text(encoding='utf-8')
marker = "  test('parses recurring late and no-travel attendance capabilities', () {"
if marker not in test_text:
    insert = r'''

  test('parses recurring late and no-travel attendance capabilities', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 700,
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'isRecurring': true,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 701,
              'sequence': 1,
              'sessionType': 'recurring_cleaning',
              'date': '2026-09-06',
              'time': '10:00',
              'hours': 2,
              'status': 'worker_assigned',
              'canReportLate': true,
              'canReportNoTravel': true,
              'lateWorkerIds': <int>[42],
              'noTravelWorkerIds': <int>[42],
              'reportableLateWorkerIds': <int>[42],
              'reportableNoTravelWorkerIds': <int>[42],
              'attendance': <String, dynamic>{
                'lateGraceMinutes': 15,
                'noTravelGraceMinutes': 30,
                'minutesPastStart': 35,
                'incidents': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'workerId': 42,
                    'workerName': 'أحمد',
                    'lateReportedAt': '2026-09-06T10:20:00+03:00',
                    'noTravelReportedAt': null,
                    'action': 'wait',
                    'resolvedAt': null,
                    'note': 'سأنتظر قليلاً',
                  },
                ],
              },
              'workerAssignments': <Map<String, dynamic>>[
                <String, dynamic>{
                  'workerId': 42,
                  'workerName': 'أحمد',
                  'status': 'accepted',
                  'lateReportedAt': '2026-09-06T10:20:00+03:00',
                  'attendanceAction': 'wait',
                  'attendanceNote': 'سأنتظر قليلاً',
                },
              ],
            },
          ],
        },
      },
    });

    final session = envelope.schedule!.sessions.single;
    expect(session.canReportLate, isTrue);
    expect(session.canReportNoTravel, isTrue);
    expect(session.reportableLateWorkerIds, <int>[42]);
    expect(session.reportableNoTravelWorkerIds, <int>[42]);
    expect(session.attendance?.lateGraceMinutes, 15);
    expect(session.attendance?.noTravelGraceMinutes, 30);
    expect(session.attendance?.minutesPastStart, 35);
    expect(session.attendance?.incidents.single.workerName, 'أحمد');
    expect(session.attendance?.incidents.single.action, 'wait');
    expect(session.attendance?.incidents.single.isNoTravel, isFalse);
    expect(session.workerAssignments.single.attendanceAction, 'wait');
    expect(session.workerAssignments.single.attendanceNote, 'سأنتظر قليلاً');
  });
'''
    pos = test_text.rfind('\n}')
    if pos < 0:
        raise SystemExit('test main closing brace not found')
    test_text = test_text[:pos] + insert + test_text[pos:]
    test_path.write_text(test_text, encoding='utf-8')
