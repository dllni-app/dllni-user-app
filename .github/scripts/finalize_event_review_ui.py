from pathlib import Path


def replace(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f'pattern not found in {path}: {old[:160]!r}')
    p.write_text(text.replace(old, new, 1))


# Parse parent-level event review capability from the schedule envelope.
path = 'lib/features/orders/data/models/cleaning_booking_schedule_model.dart'
replace(
    path,
    """  final String? currency;\n  final CleaningBookingScheduleModel? schedule;\n  final CleaningBookingSessionModel? session;\n\n  const CleaningMultiDayOrderEnvelope({\n    this.bookingId,\n    this.bookingNumber,\n    this.status,\n    this.totalPrice,\n    this.currency,\n    this.schedule,\n    this.session,\n  });\n""",
    """  final String? currency;\n  final bool canReview;\n  final bool hasReview;\n  final CleaningBookingScheduleModel? schedule;\n  final CleaningBookingSessionModel? session;\n\n  const CleaningMultiDayOrderEnvelope({\n    this.bookingId,\n    this.bookingNumber,\n    this.status,\n    this.totalPrice,\n    this.currency,\n    this.canReview = false,\n    this.hasReview = false,\n    this.schedule,\n    this.session,\n  });\n""",
)
replace(
    path,
    """      status: _string(order['status']),\n      totalPrice: _double(order['totalPrice'] ?? order['total_price']),\n      currency: _string(order['currency']),\n      schedule: scheduleRaw is Map\n""",
    """      status: _string(order['status']),\n      totalPrice: _double(order['totalPrice'] ?? order['total_price']),\n      currency: _string(order['currency']),\n      canReview: _bool(order['canReview'] ?? order['can_review']) ?? false,\n      hasReview: _bool(order['hasReview'] ?? order['has_review']) ?? false,\n      schedule: scheduleRaw is Map\n""",
)

# Add one parent-level review flow to event details. No per-day rating is introduced.
path = 'lib/features/orders/view/screens/multi_day_cleaning_order_details_screen.dart'
replace(
    path,
    """import 'package:common_package/common_package.dart';\nimport 'package:dllni_user_app/core/di/injection.dart';\n""",
    """import 'package:common_package/common_package.dart';\nimport 'package:dartz/dartz.dart' hide State;\nimport 'package:dllni_user_app/core/di/injection.dart';\n""",
)
replace(
    path,
    """import '../../data/source/cleaning_session_remote_data_source.dart';\nimport 'multi_day_cleaning_order_reschedule_screen.dart';\n""",
    """import '../../data/source/cleaning_session_remote_data_source.dart';\nimport '../../domain/usecases/submit_cleaning_review_use_case.dart';\nimport 'multi_day_cleaning_order_reschedule_screen.dart';\n""",
)
replace(
    path,
    """  int? _busySessionId;\n  String? _error;\n  String? _actionError;\n""",
    """  int? _busySessionId;\n  bool _submittingReview = false;\n  String? _error;\n  String? _actionError;\n""",
)
marker = """  Future<bool> _confirmDialog({\n"""
review_methods = """  Future<void> _openEventReview() async {\n    final envelope = _envelope;\n    if (envelope == null || !envelope.canReview || _submittingReview) return;\n\n    final result = await showDialog<_EventReviewDraft>(\n      context: context,\n      builder: (dialogContext) => const _EventReviewDialog(),\n    );\n    if (!mounted || result == null) return;\n\n    setState(() {\n      _submittingReview = true;\n      _actionError = null;\n    });\n\n    final Either<Failure, dynamic> response =\n        await getIt<SubmitCleaningReviewUseCase>()(\n          SubmitCleaningReviewParams(\n            orderId: widget.orderId,\n            rating: result.rating,\n            comment: result.comment,\n          ),\n        );\n\n    if (!mounted) return;\n    setState(() => _submittingReview = false);\n\n    await response.fold(\n      (failure) async {\n        setState(() => _actionError = failure.message);\n      },\n      (_) async {\n        ScaffoldMessenger.of(context).showSnackBar(\n          const SnackBar(content: Text('تم إرسال تقييم المناسبة بنجاح')),\n        );\n        await _load();\n      },\n    );\n  }\n\n""" + marker
replace(path, marker, review_methods)
replace(
    path,
    """        const SizedBox(height: 16),\n        AppText.titleSmall(\n          'أيام التنفيذ',\n""",
    """        if (_envelope?.canReview == true || _envelope?.hasReview == true) ...[\n          const SizedBox(height: 12),\n          _eventReviewCard(),\n        ],\n        const SizedBox(height: 16),\n        AppText.titleSmall(\n          'أيام التنفيذ',\n""",
)
replace(
    path,
    """  Widget _sessionCard(CleaningBookingSessionModel session, int totalDays) {\n""",
    """  Widget _eventReviewCard() {\n    final submitted = _envelope?.hasReview == true;\n\n    return _card(\n      children: [\n        Row(\n          children: [\n            Icon(\n              submitted ? Icons.star_rounded : Icons.star_border_rounded,\n              color: const Color(0xFFF59E0B),\n            ),\n            const SizedBox(width: 8),\n            Expanded(\n              child: AppText.bodyLarge(\n                submitted ? 'تم تقييم المناسبة' : 'تقييم المناسبة',\n                fontWeight: FontWeight.w800,\n                textAlign: TextAlign.start,\n              ),\n            ),\n          ],\n        ),\n        const SizedBox(height: 8),\n        AppText.bodySmall(\n          submitted\n              ? 'شكراً لك. تم حفظ تقييم واحد لتجربة المناسبة كاملة.'\n              : 'بعد اكتمال جميع أيام المناسبة، أرسل تقييماً واحداً عن التجربة كاملة بدلاً من تقييم كل يوم بشكل منفصل.',\n          color: const Color(0xFF6B7280),\n          fontWeight: FontWeight.w600,\n          textAlign: TextAlign.start,\n        ),\n        if (!submitted) ...[\n          const SizedBox(height: 12),\n          FilledButton.icon(\n            onPressed: _submittingReview ? null : _openEventReview,\n            icon: _submittingReview\n                ? const SizedBox(\n                    width: 18,\n                    height: 18,\n                    child: CircularProgressIndicator(strokeWidth: 2),\n                  )\n                : const Icon(Icons.rate_review_outlined),\n            label: const Text('تقييم المناسبة كاملة'),\n          ),\n        ],\n      ],\n    );\n  }\n\n  Widget _sessionCard(CleaningBookingSessionModel session, int totalDays) {\n""",
)

# Add private dialog classes after the screen state.
p = Path(path)
text = p.read_text()
append = r'''

class _EventReviewDraft {
  const _EventReviewDraft({required this.rating, this.comment});

  final int rating;
  final String? comment;
}

class _EventReviewDialog extends StatefulWidget {
  const _EventReviewDialog();

  @override
  State<_EventReviewDialog> createState() => _EventReviewDialogState();
}

class _EventReviewDialogState extends State<_EventReviewDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقييم المناسبة كاملة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('كيف كانت تجربتك الإجمالية مع فريق المناسبة؟'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final selected = _rating >= index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  Icons.star_rounded,
                  size: 34,
                  color: selected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'ملاحظات عن تجربة المناسبة (اختياري)',
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
                  final comment = _commentController.text.trim();
                  Navigator.of(context).pop(
                    _EventReviewDraft(
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
'''
if append.strip() not in text:
    p.write_text(text.rstrip() + append + '\n')

# Lightweight contract tests without touching the older large model test file.
Path('test/features/orders/data/models/cleaning_event_review_state_test.dart').write_text(r'''import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses parent event review capability from schedule envelope', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 77,
        'status': 'completed',
        'canReview': true,
        'hasReview': false,
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'daysCount': 2,
          'completedDaysCount': 2,
          'cancelledDaysCount': 0,
          'remainingDaysCount': 0,
          'totalHours': 8,
          'sessions': <Map<String, dynamic>>[],
        },
      },
    });

    expect(envelope.canReview, isTrue);
    expect(envelope.hasReview, isFalse);
  });

  test('defaults event review capability to false for legacy payloads', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{'id': 78, 'status': 'in_progress'},
    });

    expect(envelope.canReview, isFalse);
    expect(envelope.hasReview, isFalse);
  });
}
''')

Path('test/features/orders/domain/usecases/submit_cleaning_review_use_case_test.dart').parent.mkdir(parents=True, exist_ok=True)
Path('test/features/orders/domain/usecases/submit_cleaning_review_use_case_test.dart').write_text(r'''import 'package:dllni_user_app/features/orders/domain/usecases/submit_cleaning_review_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event review body omits workerId for one parent-level rating', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      rating: 5,
      comment: 'ممتاز',
    ).getBody();

    expect(body['rating'], 5);
    expect(body['comment'], 'ممتاز');
    expect(body.containsKey('workerId'), isFalse);
  });

  test('regular worker review body keeps workerId', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      workerId: 7,
      rating: 4,
    ).getBody();

    expect(body['workerId'], 7);
  });
}
''')
