import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats recurring session API values canonically', () {
    final session = CleaningRecurringSessionInput(
      date: DateTime(2026, 9, 7),
      time: '09:30',
    );

    expect(session.dateApi, '2026-09-07');
    expect(session.slotKey, '2026-09-07|09:30');
    expect(session.toJson(), <String, dynamic>{
      'date': '2026-09-07',
      'time': '09:30',
    });
  });

  test('normalizes visits before serializing the recurring schedule', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 21), time: '18:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 7), time: '09:30'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 14), time: '12:00'),
    ];

    expect(sessions.normalized.map((item) => item.slotKey).toList(), <String>[
      '2026-09-07|09:30',
      '2026-09-14|12:00',
      '2026-09-21|18:00',
    ]);
    expect(sessions.scheduleJson, <String, dynamic>{
      'mode': 'recurring',
      'sessions': <Map<String, dynamic>>[
        <String, dynamic>{'date': '2026-09-07', 'time': '09:30'},
        <String, dynamic>{'date': '2026-09-14', 'time': '12:00'},
        <String, dynamic>{'date': '2026-09-21', 'time': '18:00'},
      ],
    });
  });

  test('generates daily visits from the canonical first visit', () {
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.daily,
      startDate: DateTime(2026, 9, 7),
      time: '09:30',
      occurrences: 4,
    );

    expect(sessions.map((item) => item.dateApi).toList(), <String>[
      '2026-09-07',
      '2026-09-08',
      '2026-09-09',
      '2026-09-10',
    ]);
    expect(sessions.every((item) => item.time == '09:30'), isTrue);
  });

  test('generates weekly visits and reports the maximum 30-day count', () {
    final startDate = DateTime(2026, 9, 7);
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.weekly,
      startDate: startDate,
      time: '12:00',
      occurrences: 5,
    );

    expect(sessions.map((item) => item.dateApi).toList(), <String>[
      '2026-09-07',
      '2026-09-14',
      '2026-09-21',
      '2026-09-28',
      '2026-10-05',
    ]);
    expect(
      CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
        pattern: CleaningRecurringPattern.weekly,
        startDate: startDate,
      ),
      5,
    );
  });

  test('generates monthly visits with end-of-month clamping', () {
    final next = CleaningRecurringScheduleGenerator.occurrenceDate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: DateTime(2027, 1, 31),
      occurrenceIndex: 1,
    );

    expect(next, DateTime(2027, 2, 28));
  });

  test('does not silently truncate generated visits beyond thirty days', () {
    expect(
      () => CleaningRecurringScheduleGenerator.generate(
        pattern: CleaningRecurringPattern.daily,
        startDate: DateTime(2026, 9, 1),
        time: '09:00',
        occurrences: 32,
      ),
      throwsRangeError,
    );
  });

  test('allows recurring visits spanning exactly thirty days', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 1), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 10, 1), time: '09:00'),
    ];

    expect(sessions.windowDays, cleaningRecurringMaxWindowDays);
    expect(sessions.exceedsMaxWindow, isFalse);
  });

  test('rejects recurring visit models spanning more than thirty days', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 1), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 10, 2), time: '09:00'),
    ];

    expect(sessions.windowDays, 31);
    expect(sessions.exceedsMaxWindow, isTrue);
  });

  test('does not serialize a recurring schedule for an empty visit list', () {
    const sessions = <CleaningRecurringSessionInput>[];

    expect(sessions.scheduleJson, isNull);
  });
}
