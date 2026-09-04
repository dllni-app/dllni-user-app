import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
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
