import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_event_session.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sessions = <CleaningEventSessionInput>[
    CleaningEventSessionInput(
      date: DateTime(2026, 9, 12),
      time: '17:30',
      hours: 5,
    ),
    CleaningEventSessionInput(
      date: DateTime(2026, 9, 10),
      time: '18:00',
      hours: 4,
    ),
  ];

  test('event create serializes one parent booking with sorted sessions', () {
    final body = CreateCleaningOrderParams.eventAssistance(
      addressId: 18,
      scheduledDate: '2099-01-01',
      scheduledTime: '01:00',
      eventType: 'birthday',
      guestCount: 120,
      venueType: 'villa',
      customService: 'Event assistance',
      hours: 1,
      eventSessions: sessions,
      numberOfWorkers: 3,
    ).getBody();

    expect(body['scheduledDate'], '2026-09-10');
    expect(body['scheduledTime'], '18:00');
    expect((body['propertyDetails'] as Map)['hours'], 9.0);
    expect(body['schedule'], {
      'mode': 'multi_day',
      'sessions': [
        {'date': '2026-09-10', 'time': '18:00', 'hours': 4.0},
        {'date': '2026-09-12', 'time': '17:30', 'hours': 5.0},
      ],
    });
    expect(body['numberOfWorkers'], 3);
  });

  test('event estimate sends schedule and aggregate event hours', () {
    final body = EstimateCleaningPriceParams.eventAssistance(
      eventType: 'birthday',
      guestCount: 120,
      venueType: 'villa',
      customService: 'Event assistance',
      hours: 1,
      eventSessions: sessions,
      addressId: 18,
      numberOfWorkers: 3,
    ).getBody();

    expect((body['propertyDetails'] as Map)['hours'], 9.0);
    expect(body['schedule'], {
      'mode': 'multi_day',
      'sessions': [
        {'date': '2026-09-10', 'time': '18:00', 'hours': 4.0},
        {'date': '2026-09-12', 'time': '17:30', 'hours': 5.0},
      ],
    });
  });

  test('one event session keeps legacy request compatibility', () {
    final body = CreateCleaningOrderParams.eventAssistance(
      addressId: 18,
      scheduledDate: '2026-09-10',
      scheduledTime: '18:00',
      eventType: 'birthday',
      guestCount: 20,
      venueType: 'villa',
      customService: 'Event assistance',
      hours: 4,
      eventSessions: <CleaningEventSessionInput>[
        CleaningEventSessionInput(
          date: DateTime(2026, 9, 10),
          time: '18:00',
          hours: 4,
        ),
      ],
    ).getBody();

    expect(body.containsKey('schedule'), isFalse);
    expect(body['scheduledDate'], '2026-09-10');
    expect(body['scheduledTime'], '18:00');
  });
}
