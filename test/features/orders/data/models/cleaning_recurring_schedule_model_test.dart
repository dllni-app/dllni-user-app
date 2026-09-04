import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('session model preserves recurring cleaning session type', () {
    final schedule = CleaningBookingScheduleModel.fromJson({
      'mode': 'multi_day',
      'sessions': [
        {
          'id': 81,
          'sequence': 1,
          'sessionType': 'recurring_cleaning',
          'date': '2026-09-12',
          'time': '09:00',
          'hours': 2,
          'status': 'scheduled',
          'canSkip': true,
        },
      ],
    });

    expect(schedule.sessions, hasLength(1));
    expect(schedule.sessions.single.sessionType, 'recurring_cleaning');
    expect(schedule.sessions.single.canSkip, isTrue);
  });

  test(
    'skipped recurring visit is terminal and excluded from fallback hours',
    () {
      final schedule = CleaningBookingScheduleModel.fromJson({
        'mode': 'multi_day',
        'sessions': [
          {
            'id': 91,
            'sequence': 1,
            'sessionType': 'recurring_cleaning',
            'date': '2026-09-12',
            'time': '09:00',
            'hours': 2,
            'status': 'skipped',
            'skippedAt': '2026-09-10T08:00:00+03:00',
            'skipReason': 'لا نحتاج الزيارة هذا الأسبوع',
          },
          {
            'id': 92,
            'sequence': 2,
            'sessionType': 'recurring_cleaning',
            'date': '2026-09-19',
            'time': '09:00',
            'hours': 3,
            'status': 'scheduled',
            'canSkip': true,
          },
        ],
      });

      expect(schedule.sessions.first.isSkipped, isTrue);
      expect(schedule.sessions.first.isTerminal, isTrue);
      expect(schedule.sessions.first.canSkip, isFalse);
      expect(
        schedule.sessions.first.skipReason,
        'لا نحتاج الزيارة هذا الأسبوع',
      );
      expect(schedule.skippedDaysCount, 1);
      expect(schedule.remainingDaysCount, 1);
      expect(schedule.totalHours, 3);
    },
  );

  test('recurring schedule preserves server pause and resume capabilities', () {
    final schedule = CleaningBookingScheduleModel.fromJson({
      'mode': 'multi_day',
      'isRecurring': true,
      'isPaused': true,
      'canPause': false,
      'canResume': true,
      'pausedAt': '2026-09-10T08:00:00+03:00',
      'pauseReason': 'سفر لمدة أسبوع',
      'sessions': [
        {
          'id': 101,
          'sequence': 1,
          'sessionType': 'recurring_cleaning',
          'date': '2026-09-12',
          'time': '09:00',
          'hours': 2,
          'status': 'paused',
          'canSkip': false,
        },
      ],
    });

    expect(schedule.isRecurring, isTrue);
    expect(schedule.isPaused, isTrue);
    expect(schedule.canPause, isFalse);
    expect(schedule.canResume, isTrue);
    expect(schedule.pausedAt, '2026-09-10T08:00:00+03:00');
    expect(schedule.pauseReason, 'سفر لمدة أسبوع');
    expect(schedule.hasRecurringSeriesState, isTrue);
    expect(schedule.sessions.single.isPaused, isTrue);
    expect(schedule.sessions.single.isTerminal, isFalse);
    expect(schedule.remainingDaysCount, 1);
    expect(schedule.totalHours, 2);
  });
}
