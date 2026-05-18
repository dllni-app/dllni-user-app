import 'package:dllni_user_app/features/cl_main/view/helpers/cl_service_schedule_time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatClServiceEndTime', () {
    test('adds estimated hours to start time', () {
      expect(
        formatClServiceEndTime(startTime: '09:00', durationHours: 5),
        '14:00',
      );
    });

    test('supports fractional hours', () {
      expect(
        formatClServiceEndTime(startTime: '09:00', durationHours: 5.5),
        '14:30',
      );
    });

    test('wraps past midnight', () {
      expect(
        formatClServiceEndTime(startTime: '22:00', durationHours: 3),
        '01:00',
      );
    });
  });
}
