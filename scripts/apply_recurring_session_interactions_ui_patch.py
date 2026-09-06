from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    if old not in text:
        raise SystemExit(f"missing patch anchor in {path}: {old[:120]!r}")
    file.write_text(text.replace(old, new, 1))


# 1) Parse per-session financial/review/dispute state.
path = "lib/features/orders/data/models/cleaning_booking_schedule_model.dart"
replace_once(
    path,
    "class CleaningSessionWorkerAssignmentModel {",
    """class CleaningSessionPaymentModel {\n  final String status;\n  final double? amount;\n  final String? currency;\n  final String? settledAt;\n  final bool isInternalSettlement;\n\n  const CleaningSessionPaymentModel({\n    required this.status,\n    this.amount,\n    this.currency,\n    this.settledAt,\n    this.isInternalSettlement = true,\n  });\n\n  factory CleaningSessionPaymentModel.fromJson(Map<String, dynamic> json) {\n    return CleaningSessionPaymentModel(\n      status: _string(json['status']) ?? 'pending',\n      amount: _double(json['amount']),\n      currency: _string(json['currency']),\n      settledAt: _string(json['settledAt'] ?? json['settled_at']),\n      isInternalSettlement:\n          _bool(json['isInternalSettlement'] ?? json['is_internal_settlement']) ??\n          true,\n    );\n  }\n}\n\nclass CleaningSessionWorkerAssignmentModel {""",
)
replace_once(
    path,
    "  final bool? canReschedule;\n  final CleaningSessionPricingModel? pricing;",
    """  final bool? canReschedule;\n  final CleaningSessionPaymentModel? payment;\n  final String paymentStatus;\n  final String? paymentSettledAt;\n  final bool canReview;\n  final bool hasReview;\n  final List<int> reviewedWorkerIds;\n  final List<int> reviewableWorkerIds;\n  final bool canOpenDispute;\n  final bool hasOpenDispute;\n  final int? disputeId;\n  final String? disputeStatus;\n  final CleaningSessionPricingModel? pricing;""",
)
replace_once(
    path,
    "    this.canReschedule,\n    this.pricing,",
    """    this.canReschedule,\n    this.payment,\n    this.paymentStatus = 'pending',\n    this.paymentSettledAt,\n    this.canReview = false,\n    this.hasReview = false,\n    this.reviewedWorkerIds = const <int>[],\n    this.reviewableWorkerIds = const <int>[],\n    this.canOpenDispute = false,\n    this.hasOpenDispute = false,\n    this.disputeId,\n    this.disputeStatus,\n    this.pricing,""",
)
replace_once(
    path,
    "      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),\n      pricing: json['pricing'] is Map",
    """      canReschedule: _bool(json['canReschedule'] ?? json['can_reschedule']),\n      payment: json['payment'] is Map\n          ? CleaningSessionPaymentModel.fromJson(_map(json['payment']))\n          : null,\n      paymentStatus:\n          _string(json['paymentStatus'] ?? json['payment_status']) ??\n          _string(_map(json['payment'])['status']) ??\n          'pending',\n      paymentSettledAt:\n          _string(json['paymentSettledAt'] ?? json['payment_settled_at']) ??\n          _string(_map(json['payment'])['settledAt']),\n      canReview: _bool(json['canReview'] ?? json['can_review']) ?? false,\n      hasReview: _bool(json['hasReview'] ?? json['has_review']) ?? false,\n      reviewedWorkerIds:\n          (json['reviewedWorkerIds'] ?? json['reviewed_worker_ids']) is List\n          ? (json['reviewedWorkerIds'] ?? json['reviewed_worker_ids'] as List)\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      reviewableWorkerIds:\n          (json['reviewableWorkerIds'] ?? json['reviewable_worker_ids']) is List\n          ? (json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'] as List)\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      canOpenDispute:\n          _bool(json['canOpenDispute'] ?? json['can_open_dispute']) ?? false,\n      hasOpenDispute:\n          _bool(json['hasOpenDispute'] ?? json['has_open_dispute']) ?? false,\n      disputeId: _int(json['disputeId'] ?? json['dispute_id']),\n      disputeStatus: _string(json['disputeStatus'] ?? json['dispute_status']),\n      pricing: json['pricing'] is Map""",
)

# Fix nullable list expression precedence into local vars before constructor.
replace_once(
    path,
    "    final rawAssignmentState =\n        json['workerAssignmentState'] ?? json['worker_assignment_state'];\n\n    return CleaningBookingSessionModel(",
    """    final rawAssignmentState =\n        json['workerAssignmentState'] ?? json['worker_assignment_state'];\n    final rawReviewedWorkerIds =\n        json['reviewedWorkerIds'] ?? json['reviewed_worker_ids'];\n    final rawReviewableWorkerIds =\n        json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'];\n\n    return CleaningBookingSessionModel(""",
)
replace_once(
    path,
    """      reviewedWorkerIds:\n          (json['reviewedWorkerIds'] ?? json['reviewed_worker_ids']) is List\n          ? (json['reviewedWorkerIds'] ?? json['reviewed_worker_ids'] as List)\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      reviewableWorkerIds:\n          (json['reviewableWorkerIds'] ?? json['reviewable_worker_ids']) is List\n          ? (json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'] as List)\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],""",
    """      reviewedWorkerIds: rawReviewedWorkerIds is List\n          ? rawReviewedWorkerIds\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],\n      reviewableWorkerIds: rawReviewableWorkerIds is List\n          ? rawReviewableWorkerIds\n                .map(_int)\n                .whereType<int>()\n                .toList(growable: false)\n          : const <int>[],""",
)

# 2) Session interaction API calls.
path = "lib/features/orders/data/source/cleaning_session_remote_data_source.dart"
replace_once(
    path,
    "  Future<CleaningMultiDayOrderEnvelope> sendSos({",
    """  Future<CleaningMultiDayOrderEnvelope> submitSessionReview({\n    required int orderId,\n    required int sessionId,\n    required int workerId,\n    required int rating,\n    String? comment,\n  }) {\n    final data = <String, dynamic>{'workerId': workerId, 'rating': rating};\n    final normalizedComment = comment?.trim();\n    if (normalizedComment != null && normalizedComment.isNotEmpty) {\n      data['comment'] = normalizedComment;\n    }\n\n    return _post(\n      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/review',\n      data: data,\n    );\n  }\n\n  Future<CleaningMultiDayOrderEnvelope> openSessionDispute({\n    required int orderId,\n    required int sessionId,\n    required String description,\n    required String category,\n  }) {\n    return _post(\n      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/disputes',\n      data: <String, dynamic>{\n        'description': description.trim(),\n        'category': category,\n      },\n    );\n  }\n\n  Future<CleaningMultiDayOrderEnvelope> sendSos({""",
)

# 3) Recurring UI actions.
path = "lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart"
replace_once(
    path,
    "  Future<String?> _askSecurityCode() async {",
    """  Future<void> _reviewRecurringSession(\n    CleaningBookingSessionModel session,\n  ) async {\n    final sessionId = session.id;\n    if (!widget.recurring ||\n        sessionId == null ||\n        !session.canReview ||\n        _busySessionId != null) {\n      return;\n    }\n\n    final reviewableIds = session.reviewableWorkerIds.toSet();\n    final workers = session.workerAssignments\n        .where(\n          (assignment) =>\n              assignment.workerId != null &&\n              reviewableIds.contains(assignment.workerId),\n        )\n        .map(\n          (assignment) => _EventReviewWorker(\n            workerId: assignment.workerId!,\n            workerName: assignment.workerName?.trim().isNotEmpty == true\n                ? assignment.workerName!.trim()\n                : 'العامل #${assignment.workerId}',\n          ),\n        )\n        .toList(growable: false);\n\n    if (workers.isEmpty) {\n      setState(() => _actionError = 'تعذر تحديد العامل القابل للتقييم لهذه الزيارة.');\n      return;\n    }\n\n    final draft = await showDialog<_RecurringSessionReviewDraft>(\n      context: context,\n      builder: (dialogContext) =>\n          _RecurringSessionReviewDialog(workers: workers),\n    );\n    if (!mounted || draft == null) return;\n\n    await _runSessionAction(\n      session,\n      () => _sessions.submitSessionReview(\n        orderId: widget.orderId,\n        sessionId: sessionId,\n        workerId: draft.workerId,\n        rating: draft.rating,\n        comment: draft.comment,\n      ),\n    );\n  }\n\n  Future<void> _openRecurringSessionDispute(\n    CleaningBookingSessionModel session,\n  ) async {\n    final sessionId = session.id;\n    if (!widget.recurring ||\n        sessionId == null ||\n        !session.canOpenDispute ||\n        _busySessionId != null) {\n      return;\n    }\n\n    final draft = await showDialog<_RecurringSessionDisputeDraft>(\n      context: context,\n      builder: (dialogContext) => const _RecurringSessionDisputeDialog(),\n    );\n    if (!mounted || draft == null) return;\n\n    await _runSessionAction(\n      session,\n      () => _sessions.openSessionDispute(\n        orderId: widget.orderId,\n        sessionId: sessionId,\n        description: draft.description,\n        category: draft.category,\n      ),\n    );\n  }\n\n  Future<String?> _askSecurityCode() async {""",
)
replace_once(
    path,
    "        if (_envelope?.canReview == true || _envelope?.hasReview == true) ...[",
    "        if (!widget.recurring &&\n            (_envelope?.canReview == true || _envelope?.hasReview == true)) ...[",
)
replace_once(
    path,
    "          if (session.isCancelled && cancellationFee > 0) ...[",
    """          if (widget.recurring &&\n              (session.isCompleted ||\n                  session.paymentStatus == 'ready' ||\n                  session.paymentStatus == 'settled')) ...[\n            const SizedBox(height: 7),\n            _infoRow(\n              'التسوية المالية',\n              _paymentStatusLabel(session.paymentStatus),\n            ),\n          ],\n          if (widget.recurring && session.hasOpenDispute) ...[\n            const SizedBox(height: 7),\n            _infoRow(\n              'حالة النزاع',\n              _disputeStatusLabel(session.disputeStatus),\n            ),\n          ],\n          if (session.isCancelled && cancellationFee > 0) ...[""",
)
replace_once(
    path,
    "        session.canCancel ||\n        session.canSendSos;",
    """        session.canCancel ||\n        session.canSendSos ||\n        (widget.recurring && (session.canReview || session.canOpenDispute));""",
)
replace_once(
    path,
    "        if (session.canCancel || session.canSendSos) ...[",
    """        if (widget.recurring && (session.canReview || session.canOpenDispute)) ...[\n          if (session.canConfirmStartVerification ||\n              session.canConfirmCompletion ||\n              session.canSkip)\n            const SizedBox(height: 8),\n          Row(\n            children: [\n              if (session.canReview)\n                Expanded(\n                  child: FilledButton.icon(\n                    onPressed: busy ? null : () => _reviewRecurringSession(session),\n                    icon: const Icon(Icons.star_outline_rounded),\n                    label: const Text('تقييم الزيارة'),\n                  ),\n                ),\n              if (session.canReview && session.canOpenDispute)\n                const SizedBox(width: 8),\n              if (session.canOpenDispute)\n                Expanded(\n                  child: OutlinedButton.icon(\n                    onPressed: busy\n                        ? null\n                        : () => _openRecurringSessionDispute(session),\n                    icon: const Icon(Icons.report_problem_outlined),\n                    label: const Text('فتح نزاع'),\n                  ),\n                ),\n            ],\n          ),\n        ],\n        if (session.canCancel || session.canSendSos) ...[""",
)
replace_once(
    path,
    "  String _hours(double value) =>",
    """  String _paymentStatusLabel(String status) {\n    switch (status.trim().toLowerCase()) {\n      case 'ready':\n        return 'بانتظار تأكيد إكمال الزيارة';\n      case 'settled':\n        return 'تمت تسوية الزيارة';\n      case 'not_required':\n        return 'لا توجد تسوية لهذه الزيارة';\n      default:\n        return 'قيد الانتظار';\n    }\n  }\n\n  String _disputeStatusLabel(String? status) {\n    switch (status?.trim().toLowerCase()) {\n      case 'open':\n        return 'مفتوح';\n      case 'under_review':\n        return 'قيد المراجعة';\n      case 'resolved':\n        return 'تم الحل';\n      case 'closed':\n        return 'مغلق';\n      case 'rejected':\n        return 'مرفوض';\n      default:\n        return 'غير محدد';\n    }\n  }\n\n  String _hours(double value) =>""",
)

# Add small dialogs before the existing event review classes.
replace_once(
    path,
    "class _EventReviewWorker {",
    r'''class _RecurringSessionReviewDraft {
  const _RecurringSessionReviewDraft({
    required this.workerId,
    required this.rating,
    this.comment,
  });

  final int workerId;
  final int rating;
  final String? comment;
}

class _RecurringSessionReviewDialog extends StatefulWidget {
  const _RecurringSessionReviewDialog({required this.workers});

  final List<_EventReviewWorker> workers;

  @override
  State<_RecurringSessionReviewDialog> createState() =>
      _RecurringSessionReviewDialogState();
}

class _RecurringSessionReviewDialogState
    extends State<_RecurringSessionReviewDialog> {
  late int _workerId;
  int _rating = 0;
  final TextEditingController _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _workerId = widget.workers.first.workerId;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقييم هذه الزيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.workers.length > 1) ...[
            DropdownButtonFormField<int>(
              initialValue: _workerId,
              decoration: const InputDecoration(labelText: 'العامل'),
              items: widget.workers
                  .map(
                    (worker) => DropdownMenuItem<int>(
                      value: worker.workerId,
                      child: Text(worker.workerName),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _workerId = value);
              },
            ),
            const SizedBox(height: 12),
          ] else
            Text(
              widget.workers.first.workerName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = value),
                icon: Icon(
                  Icons.star_rounded,
                  color: _rating >= value
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'ملاحظات عن هذه الزيارة (اختياري)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _rating < 1
              ? null
              : () {
                  final comment = _comment.text.trim();
                  Navigator.of(context).pop(
                    _RecurringSessionReviewDraft(
                      workerId: _workerId,
                      rating: _rating,
                      comment: comment.isEmpty ? null : comment,
                    ),
                  );
                },
          child: const Text('إرسال التقييم'),
        ),
      ],
    );
  }
}

class _RecurringSessionDisputeDraft {
  const _RecurringSessionDisputeDraft({
    required this.category,
    required this.description,
  });

  final String category;
  final String description;
}

class _RecurringSessionDisputeDialog extends StatefulWidget {
  const _RecurringSessionDisputeDialog();

  @override
  State<_RecurringSessionDisputeDialog> createState() =>
      _RecurringSessionDisputeDialogState();
}

class _RecurringSessionDisputeDialogState
    extends State<_RecurringSessionDisputeDialog> {
  static const Map<String, String> _categories = <String, String>{
    'poor_quality': 'جودة الخدمة',
    'property_damage': 'ضرر بالممتلكات',
    'unprofessional': 'سلوك غير مهني',
    'billing_issue': 'مشكلة مالية',
    'financial_or_verbal_dispute': 'نزاع مالي أو لفظي',
    'other': 'سبب آخر',
  };

  String _category = 'poor_quality';
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('فتح نزاع لهذه الزيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'نوع المشكلة'),
            items: _categories.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'اشرح المشكلة الخاصة بهذه الزيارة',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _description.text.trim().length < 3
              ? null
              : () => Navigator.of(context).pop(
                  _RecurringSessionDisputeDraft(
                    category: _category,
                    description: _description.text.trim(),
                  ),
                ),
          child: const Text('فتح النزاع'),
        ),
      ],
    );
  }
}

class _EventReviewWorker {''',
)

# 4) Model contract test.
path = "test/features/orders/data/models/cleaning_booking_schedule_model_test.dart"
replace_once(
    path,
    "  test('parses single-day schedule fallback without child session id', () {",
    r'''  test('parses recurring session payment review and dispute capabilities', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 712,
        'schedule': <String, dynamic>{
          'mode': 'recurring',
          'isRecurring': true,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 991,
              'sequence': 1,
              'sessionType': 'recurring_cleaning',
              'date': '2026-09-11',
              'time': '10:00',
              'hours': 2,
              'status': 'completed',
              'paymentStatus': 'settled',
              'paymentSettledAt': '2026-09-11T12:00:00+03:00',
              'payment': <String, dynamic>{
                'status': 'settled',
                'amount': 1100,
                'currency': 'SYP',
                'settledAt': '2026-09-11T12:00:00+03:00',
                'isInternalSettlement': true,
              },
              'canReview': true,
              'hasReview': true,
              'reviewedWorkerIds': <int>[41],
              'reviewableWorkerIds': <int>[42],
              'canOpenDispute': false,
              'hasOpenDispute': true,
              'disputeId': 77,
              'disputeStatus': 'open',
            },
          ],
        },
      },
    });

    final session = envelope.schedule!.sessions.single;
    expect(session.paymentStatus, 'settled');
    expect(session.payment?.amount, 1100);
    expect(session.payment?.isInternalSettlement, isTrue);
    expect(session.canReview, isTrue);
    expect(session.reviewedWorkerIds, <int>[41]);
    expect(session.reviewableWorkerIds, <int>[42]);
    expect(session.hasOpenDispute, isTrue);
    expect(session.canOpenDispute, isFalse);
    expect(session.disputeId, 77);
    expect(session.disputeStatus, 'open');
  });

  test('parses single-day schedule fallback without child session id', () {''',
)

print('Recurring session interaction UI patch applied.')
