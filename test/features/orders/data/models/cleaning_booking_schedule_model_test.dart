import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses multi-day booking schedule and next session', () {
    final result = cleaningMultiDayOrderEnvelopeFromJson({
      'data': {
        'id': 501,
        'bookingNumber': 'CLN-202609-000501',
        'status': 'partially_completed',
        'totalPrice': 15000,
        'currency': 'SYP',
        'schedule': {
          'mode': 'multi_day',
          'daysCount': 3,
          'completedDaysCount': 1,
          'cancelledDaysCount': 0,
          'remainingDaysCount': 2,
          'totalHours': 12,
          'firstDate': '2026-09-10',
          'lastDate': '2026-09-15',
          'nextSession': {
            'id': 102,
            'sequence': 2,
            'date': '2026-09-12',
            'time': '17:30',
            'hours': 5,
            'status': 'worker_assigned',
          },
          'sessions': [
            {
              'id': 101,
              'sequence': 1,
              'date': '2026-09-10',
              'time': '18:00',
              'hours': 4,
              'status': 'completed',
            },
            {
              'id': 102,
              'sequence': 2,
              'date': '2026-09-12',
              'time': '17:30',
              'hours': 5,
              'status': 'worker_assigned',
              'canCancel': true,
            },
            {
              'id': 103,
              'sequence': 3,
              'date': '2026-09-15',
              'time': '18:00',
              'hours': 3,
              'status': 'scheduled',
            },
          ],
        },
      },
    });

    expect(result.bookingId, 501);
    expect(result.status, 'partially_completed');
    expect(result.schedule?.isMultiDay, isTrue);
    expect(result.schedule?.daysCount, 3);
    expect(result.schedule?.completedDaysCount, 1);
    expect(result.schedule?.totalHours, 12);
    expect(result.schedule?.nextSession?.id, 102);
    expect(result.schedule?.sessionById(102)?.canCancel, isTrue);
  });

  test('parses action response with session next to order', () {
    final result = cleaningMultiDayOrderEnvelopeFromJson({
      'order': {
        'id': 501,
        'status': 'partially_completed',
        'schedule': {
          'mode': 'multi_day',
          'daysCount': 2,
          'sessions': [],
        },
      },
      'session': {
        'id': 1001,
        'sequence': 1,
        'date': '2026-09-10',
        'time': '18:00',
        'hours': 4,
        'status': 'completed',
      },
    });

    expect(result.bookingId, 501);
    expect(result.session?.id, 1001);
    expect(result.session?.isCompleted, isTrue);
  });
}
