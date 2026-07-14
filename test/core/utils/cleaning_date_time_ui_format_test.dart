import 'package:dllni_user_app/core/utils/cleaning_date_time_ui_format.dart';
import 'package:dllni_user_app/core/utils/cleaning_schedule_date_time_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningScheduleDateTimeLogic', () {
    test('formatDateApi uses English yyyy-MM-dd', () {
      final date = DateTime(2026, 7, 14);
      expect(
        CleaningScheduleDateTimeLogic.formatDateApi(date),
        '2026-07-14',
      );
    });

    test('formatTimeApi uses English HH:mm', () {
      final time = DateTime(2026, 7, 14, 14, 30);
      expect(
        CleaningScheduleDateTimeLogic.formatTimeApi(time),
        '14:30',
      );
    });

    test('normalizeTimeHhMm pads hour and minute', () {
      expect(
        CleaningScheduleDateTimeLogic.normalizeTimeHhMm('9:5'),
        '09:05',
      );
    });
  });

  group('CleaningDateTimeUiFormat', () {
    test('weekday returns correct weekday name', () {
      final date = DateTime(2026, 7, 14);
      expect(CleaningDateTimeUiFormat.weekday(date), 'الثلاثاء');
    });

    test('date returns Arabic month name', () {
      final date = DateTime(2026, 7, 14);
      expect(CleaningDateTimeUiFormat.date(date), '14 تموز 2026');
    });

    test('scheduleLabel combines weekday and date', () {
      final date = DateTime(2026, 7, 14);
      expect(
        CleaningDateTimeUiFormat.scheduleLabel(date),
        'الثلاثاء، 14 تموز 2026',
      );
    });

    test('time uses صباحاً for morning hours', () {
      expect(CleaningDateTimeUiFormat.time('09:30'), '09:30 صباحاً');
      expect(CleaningDateTimeUiFormat.time('00:00'), '12:00 صباحاً');
      expect(CleaningDateTimeUiFormat.time('11:59'), '11:59 صباحاً');
    });

    test('time uses مساءً for afternoon and evening hours', () {
      expect(CleaningDateTimeUiFormat.time('14:00'), '02:00 مساءً');
      expect(CleaningDateTimeUiFormat.time('12:00'), '12:00 مساءً');
      expect(CleaningDateTimeUiFormat.time('23:45'), '11:45 مساءً');
    });

    test('timeRange joins from and to times', () {
      expect(
        CleaningDateTimeUiFormat.timeRange('09:00', '12:00'),
        '09:00 صباحاً - 12:00 مساءً',
      );
    });

    test('time returns input when invalid', () {
      expect(CleaningDateTimeUiFormat.time('invalid'), 'invalid');
      expect(CleaningDateTimeUiFormat.time('9'), '9');
    });
  });
}
