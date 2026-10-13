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
      'calculationMode': 'task',
      'sessions': <Map<String, dynamic>>[
        <String, dynamic>{'date': '2026-09-07', 'time': '09:30'},
        <String, dynamic>{'date': '2026-09-14', 'time': '12:00'},
        <String, dynamic>{'date': '2026-09-21', 'time': '18:00'},
      ],
    });
  });

  test(
    'serializes hour-based recurring schedule with half-hour normalization',
    () {
      final sessions = <CleaningRecurringSessionInput>[
        CleaningRecurringSessionInput(
          date: DateTime(2026, 9, 7),
          time: '09:00',
        ),
        CleaningRecurringSessionInput(
          date: DateTime(2026, 9, 14),
          time: '09:00',
        ),
      ];

      expect(
        sessions.scheduleJsonFor(
          calculationMode: CleaningRecurringCalculationMode.hours,
          hoursPerVisit: 2.25,
        ),
        <String, dynamic>{
          'mode': 'recurring',
          'calculationMode': 'hours',
          'hoursPerVisit': 2.5,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{'date': '2026-09-07', 'time': '09:00'},
            <String, dynamic>{'date': '2026-09-14', 'time': '09:00'},
          ],
        },
      );
      expect(
        sessions.scheduleJsonFor(
          calculationMode: CleaningRecurringCalculationMode.hours,
          hoursPerVisit: 25,
        ),
        isNull,
      );
    },
  );

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

  test('monthly never moves a missing calendar day to month end', () {
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: DateTime(2027, 1, 31),
      time: '10:00',
      occurrences: 2,
    );
    expect(sessions.map((e) => e.dateApi).toList(), [
      '2027-01-31',
      '2027-03-31',
    ]);
    expect(
      CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
        pattern: CleaningRecurringPattern.monthly,
        startDate: DateTime(2027, 1, 31),
      ),
      2,
    );
  });

  test('monthly keeps leap-day dates instead of forcing February 28', () {
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: DateTime(2028, 1, 29),
      time: '09:00',
      occurrences: 3,
    );
    expect(sessions.map((e) => e.dateApi).toList(), [
      '2028-01-29',
      '2028-02-29',
      '2028-03-29',
    ]);
  });

  test('monthly skips February 29 on non-leap years', () {
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: DateTime(2027, 1, 29),
      time: '09:00',
      occurrences: 2,
    );
    expect(sessions.map((e) => e.dateApi).toList(), [
      '2027-01-29',
      '2027-03-29',
    ]);
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

    expect(sessions.windowDays, cleaningRecurringStandardWindowDays);
    expect(sessions.exceedsMaxWindow, isFalse);
  });

  test('rejects recurring visit models spanning more than ninety days', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 1), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 12, 1), time: '09:00'),
    ];

    expect(sessions.windowDays, 91);
    expect(sessions.exceedsMaxWindow, isTrue);
  });

  test('weekly and monthly recurrence have different dates', () {
    final start = DateTime(2026, 10, 14);
    final week = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.weekly,
      startDate: start,
      time: '08:00',
      occurrences: 2,
    );
    final month = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: start,
      time: '08:00',
      occurrences: 2,
    );
    expect(week.map((e) => e.dateApi).toList(), ['2026-10-14', '2026-10-21']);
    expect(month.map((e) => e.dateApi).toList(), ['2026-10-14', '2026-11-14']);
    expect(
      CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
        pattern: CleaningRecurringPattern.monthly,
        startDate: start,
      ),
      greaterThanOrEqualTo(2),
    );
  });

  test('does not serialize a recurring schedule for an empty visit list', () {
    const sessions = <CleaningRecurringSessionInput>[];

    expect(sessions.scheduleJson, isNull);
  });
}
