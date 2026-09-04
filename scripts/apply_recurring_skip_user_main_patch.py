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
    "  final bool canCancel;\n  final bool? canReschedule;\n",
    "  final bool canCancel;\n  final bool canSkip;\n  final bool? canReschedule;\n",
    "model canSkip field",
)
text = replace_once(
    text,
    "  final String? cancelledByRole;\n  final CleaningSessionWorkerAssignmentModel? workerAssignmentState;\n",
    "  final String? cancelledByRole;\n  final String? skippedAt;\n  final String? skipReason;\n  final CleaningSessionWorkerAssignmentModel? workerAssignmentState;\n",
    "model skip metadata fields",
)
text = replace_once(
    text,
    "    required this.canCancel,\n    this.canReschedule,\n",
    "    required this.canCancel,\n    this.canSkip = false,\n    this.canReschedule,\n",
    "model canSkip constructor",
)
text = replace_once(
    text,
    "    this.cancelledByRole,\n    this.workerAssignmentState,\n",
    "    this.cancelledByRole,\n    this.skippedAt,\n    this.skipReason,\n    this.workerAssignmentState,\n",
    "model skip metadata constructor",
)
text = replace_once(
    text,
    "      canCancel: _bool(json['canCancel'] ?? json['can_cancel']) ?? false,\n      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),\n",
    "      canCancel: _bool(json['canCancel'] ?? json['can_cancel']) ?? false,\n      canSkip: _bool(json['canSkip'] ?? json['can_skip']) ?? false,\n      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),\n",
    "model canSkip parsing",
)
text = replace_once(
    text,
    "      cancelledByRole: _string(\n        json['cancelledByRole'] ?? json['cancelled_by_role'],\n      ),\n      workerAssignmentState: rawAssignmentState is Map\n",
    "      cancelledByRole: _string(\n        json['cancelledByRole'] ?? json['cancelled_by_role'],\n      ),\n      skippedAt: _string(json['skippedAt'] ?? json['skipped_at']),\n      skipReason: _string(json['skipReason'] ?? json['skip_reason']),\n      workerAssignmentState: rawAssignmentState is Map\n",
    "model skip metadata parsing",
)
text = replace_once(
    text,
    "  bool get isCancelled => status == 'cancelled';\n  bool get isTerminal =>\n      isCompleted || isCancelled || status == 'under_dispute';\n",
    "  bool get isCancelled => status == 'cancelled';\n  bool get isSkipped => status == 'skipped';\n  bool get isTerminal =>\n      isCompleted || isCancelled || isSkipped || status == 'under_dispute';\n",
    "model skipped terminal",
)
text = replace_once(
    text,
    "  final int cancelledDaysCount;\n  final int remainingDaysCount;\n",
    "  final int cancelledDaysCount;\n  final int skippedDaysCount;\n  final int remainingDaysCount;\n",
    "schedule skipped count field",
)
text = replace_once(
    text,
    "    required this.cancelledDaysCount,\n    required this.remainingDaysCount,\n",
    "    required this.cancelledDaysCount,\n    this.skippedDaysCount = 0,\n    required this.remainingDaysCount,\n",
    "schedule skipped count constructor",
)
text = replace_once(
    text,
    "      cancelledDaysCount:\n          _int(json['cancelledDaysCount'] ?? json['cancelled_days_count']) ??\n          sessions.where((item) => item.isCancelled).length,\n      remainingDaysCount:\n",
    "      cancelledDaysCount:\n          _int(json['cancelledDaysCount'] ?? json['cancelled_days_count']) ??\n          sessions.where((item) => item.isCancelled).length,\n      skippedDaysCount:\n          _int(\n            json['skippedSessionsCount'] ??\n                json['skippedDaysCount'] ??\n                json['skipped_days_count'],\n          ) ??\n          sessions.where((item) => item.isSkipped).length,\n      remainingDaysCount:\n",
    "schedule skipped count parsing",
)
text = replace_once(
    text,
    "          sessions\n              .where((item) => !item.isCancelled)\n              .fold<double>(0, (sum, item) => sum + item.hours),\n",
    "          sessions\n              .where((item) => !item.isCancelled && !item.isSkipped)\n              .fold<double>(0, (sum, item) => sum + item.hours),\n",
    "schedule total hours skipped fallback",
)
model.write_text(text)

source = Path("lib/features/orders/data/source/cleaning_session_remote_data_source.dart")
text = source.read_text()
marker = '''  Future<CleaningMultiDayOrderEnvelope> changeWorkers({
'''
method = '''  Future<CleaningMultiDayOrderEnvelope> skipSession({
    required int orderId,
    required int sessionId,
    required String reason,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/skip',
      data: <String, dynamic>{'reason': reason.trim()},
    );
  }

'''
text = replace_once(text, marker, method + marker, "datasource skip method")
source.write_text(text)

screen = Path("lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart")
text = screen.read_text()
marker = '''  Future<void> _sendSos(CleaningBookingSessionModel session) async {
'''
method = '''  Future<void> _skipSession(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canSkip) return;

    final reason = await _askText(
      title: 'تخطي هذه الزيارة',
      hint: 'سبب تخطي الزيارة',
      confirmLabel: 'متابعة',
    );
    if (reason == null) return;

    final approved = await _confirmDialog(
      title: 'تأكيد تخطي الزيارة ${session.sequence}',
      message:
          'سيتم تخطي هذه الزيارة فقط وتحرير العامل المرتبط بها دون رسوم إلغاء، وسيُعاد احتساب إجمالي الحجز. بقية الزيارات ستبقى كما هي.',
      confirmLabel: 'تخطي الزيارة',
    );
    if (!approved) return;

    await _runSessionAction(
      session,
      () => _sessions.skipSession(
        orderId: widget.orderId,
        sessionId: sessionId,
        reason: reason,
      ),
    );
  }

'''
text = replace_once(text, marker, method + marker, "screen skip method")
text = replace_once(
    text,
    "    final progressText =\n        '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة';\n",
    "    final progressText = schedule.skippedDaysCount > 0\n        ? '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة • ${schedule.skippedDaysCount} متخطاة'\n        : '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة';\n",
    "screen progress skipped count",
)
text = replace_once(
    text,
    "          if (session.isCancelled &&\n              session.cancellationReason != null &&\n              session.cancellationReason!.trim().isNotEmpty) ...[\n            const SizedBox(height: 7),\n            _infoRow('سبب الإلغاء', session.cancellationReason!.trim()),\n          ],\n          if (_hasActions(session)) ...[\n",
    "          if (session.isCancelled &&\n              session.cancellationReason != null &&\n              session.cancellationReason!.trim().isNotEmpty) ...[\n            const SizedBox(height: 7),\n            _infoRow('سبب الإلغاء', session.cancellationReason!.trim()),\n          ],\n          if (session.isSkipped &&\n              session.skipReason != null &&\n              session.skipReason!.trim().isNotEmpty) ...[\n            const SizedBox(height: 7),\n            _infoRow('سبب التخطي', session.skipReason!.trim()),\n          ],\n          if (_hasActions(session)) ...[\n",
    "screen skip reason",
)
text = replace_once(
    text,
    "        session.canConfirmCompletion ||\n        session.canCancel ||\n        session.canSendSos;\n",
    "        session.canConfirmCompletion ||\n        session.canSkip ||\n        session.canCancel ||\n        session.canSendSos;\n",
    "screen has skip action",
)
old = '''        if (session.canCancel || session.canSendSos) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion)
            const SizedBox(height: 8),
          Row(
'''
new = '''        if (session.canSkip) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion)
            const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : () => _skipSession(session),
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('تخطي هذه الزيارة'),
          ),
        ],
        if (session.canCancel || session.canSendSos) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion ||
              session.canSkip)
            const SizedBox(height: 8),
          Row(
'''
text = replace_once(text, old, new, "screen skip action button")
text = replace_once(
    text,
    "      case 'cancelled':\n        return 'ملغاة';\n      case 'under_dispute':\n",
    "      case 'cancelled':\n        return 'ملغاة';\n      case 'skipped':\n        return 'تم تخطيها';\n      case 'under_dispute':\n",
    "screen skipped status label",
)
text = replace_once(
    text,
    "      case 'cancelled':\n      case 'under_dispute':\n        return const Color(0xFFFEE2E2);\n",
    "      case 'cancelled':\n      case 'under_dispute':\n        return const Color(0xFFFEE2E2);\n      case 'skipped':\n        return const Color(0xFFFEF3C7);\n",
    "screen skipped background",
)
text = replace_once(
    text,
    "      case 'cancelled':\n      case 'under_dispute':\n        return const Color(0xFF991B1B);\n",
    "      case 'cancelled':\n      case 'under_dispute':\n        return const Color(0xFF991B1B);\n      case 'skipped':\n        return const Color(0xFF92400E);\n",
    "screen skipped foreground",
)
screen.write_text(text)

test = Path("test/features/orders/data/models/cleaning_recurring_schedule_model_test.dart")
text = test.read_text()
text = replace_once(
    text,
    "          'status': 'scheduled',\n",
    "          'status': 'scheduled',\n          'canSkip': true,\n",
    "test canSkip fixture",
)
text = replace_once(
    text,
    "    expect(schedule.sessions.single.sessionType, 'recurring_cleaning');\n  });\n}\n",
    "    expect(schedule.sessions.single.sessionType, 'recurring_cleaning');\n    expect(schedule.sessions.single.canSkip, isTrue);\n  });\n\n  test('skipped recurring visit is terminal and excluded from fallback hours', () {\n    final schedule = CleaningBookingScheduleModel.fromJson({\n      'mode': 'multi_day',\n      'sessions': [\n        {\n          'id': 91,\n          'sequence': 1,\n          'sessionType': 'recurring_cleaning',\n          'date': '2026-09-12',\n          'time': '09:00',\n          'hours': 2,\n          'status': 'skipped',\n          'skippedAt': '2026-09-10T08:00:00+03:00',\n          'skipReason': 'لا نحتاج الزيارة هذا الأسبوع',\n        },\n        {\n          'id': 92,\n          'sequence': 2,\n          'sessionType': 'recurring_cleaning',\n          'date': '2026-09-19',\n          'time': '09:00',\n          'hours': 3,\n          'status': 'scheduled',\n          'canSkip': true,\n        },\n      ],\n    });\n\n    expect(schedule.sessions.first.isSkipped, isTrue);\n    expect(schedule.sessions.first.isTerminal, isTrue);\n    expect(schedule.sessions.first.canSkip, isFalse);\n    expect(schedule.sessions.first.skipReason, 'لا نحتاج الزيارة هذا الأسبوع');\n    expect(schedule.skippedDaysCount, 1);\n    expect(schedule.remainingDaysCount, 1);\n    expect(schedule.totalHours, 3);\n  });\n}\n",
    "test skipped terminal case",
)
test.write_text(text)
