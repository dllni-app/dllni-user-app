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

  group('effectiveCleaningWorkerDurationHours', () {
    test('never rounds positive small multi-worker visit to zero', () {
      final duration = effectiveCleaningWorkerDurationHours(
        estimatedHours: 0.04,
        numberOfWorkers: 8,
      );
      expect(duration, greaterThan(0));
      expect(duration, closeTo(1 / 60, 0.000001));
      expect(
        formatClServiceEndTime(startTime: '09:00', durationHours: duration),
        '09:01',
      );
    });

    test('rounds worker share upward to next minute', () {
      expect(
        effectiveCleaningWorkerDurationHours(
          estimatedHours: 1,
          numberOfWorkers: 3,
        ),
        closeTo(20 / 60, 0.000001),
      );
      expect(
        effectiveCleaningWorkerDurationHours(
          estimatedHours: 0,
          numberOfWorkers: 3,
        ),
        0,
      );
    });
  });
}
