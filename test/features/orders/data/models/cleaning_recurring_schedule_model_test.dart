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
        },
      ],
    });

    expect(schedule.sessions, hasLength(1));
    expect(schedule.sessions.single.sessionType, 'recurring_cleaning');
  });
}
