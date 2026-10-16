import 'package:dllni_user_app/core/utils/cleaning_schedule_date_time_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cleaning schedule must be in the future', () {
    final now = DateTime(2026, 10, 16, 14, 45);

    test('rejects a date before today even if the hour is later', () {
      expect(
        CleaningScheduleDateTimeLogic.futureAppointmentError(
          date: DateTime(2026, 10, 15),
          time: '23:59',
          now: now,
        ),
        contains('تاريخ منقضٍ'),
      );
    });

    test('rejects past and current-minute times on today', () {
      for (final time in ['08:00', '14:44', '14:45']) {
        expect(
          CleaningScheduleDateTimeLogic.futureAppointmentError(
            date: DateTime(2026, 10, 16),
            time: time,
            now: now,
          ),
          contains('وقت منقضٍ'),
        );
      }
    });

    test('accepts a later time today and any time tomorrow', () {
      expect(
        CleaningScheduleDateTimeLogic.futureAppointmentError(
          date: DateTime(2026, 10, 16),
          time: '14:46',
          now: now,
        ),
        isNull,
      );
      expect(
        CleaningScheduleDateTimeLogic.futureAppointmentError(
          date: DateTime(2026, 10, 17),
          time: '00:00',
          now: now,
        ),
        isNull,
      );
    });

    test('rejects malformed times', () {
      for (final time in ['25:00', '11:65', '', 'abc']) {
        expect(
          CleaningScheduleDateTimeLogic.futureAppointmentError(
            date: DateTime(2026, 10, 17),
            time: time,
            now: now,
          ),
          contains('وقت صحيح'),
        );
      }
    });
  });
}
