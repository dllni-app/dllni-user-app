import 'cleaning_schedule_date_time_logic.dart';

/// Arabic labels for cleaning date/time UI only.
///
/// Never use these strings for API requests, persistence, comparisons, or
/// duration calculations. Use [CleaningScheduleDateTimeLogic] instead.
class CleaningDateTimeUiFormat {
  const CleaningDateTimeUiFormat._();

  static const _arabicWeekdays = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const _arabicMonths = <String>[
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  static String weekday(DateTime date) {
    return _arabicWeekdays[date.weekday - 1];
  }

  static String date(DateTime value) {
    return '${value.day} ${_arabicMonths[value.month - 1]} ${value.year}';
  }

  static String scheduleLabel(DateTime date) {
    return '${weekday(date)}، ${CleaningDateTimeUiFormat.date(date)}';
  }

  static String time(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return hhmm;

    final period = hour >= 12 ? 'مساءً' : 'صباحاً';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }

  static String timeRange(String fromHhmm, String toHhmm) {
    return '${time(fromHhmm)} - ${time(toHhmm)}';
  }

  static String weekdayFromApiDate(String? rawDate) {
    final date = CleaningScheduleDateTimeLogic.parseDateApi(rawDate);
    if (date == null) return '-';
    return weekday(date);
  }

  static String dateFromApiDate(String? rawDate) {
    final date = CleaningScheduleDateTimeLogic.parseDateApi(rawDate);
    if (date == null) return '-';
    return CleaningDateTimeUiFormat.date(date);
  }

  static String timeFromDateTime(DateTime? value) {
    if (value == null) return '-';
    return time(CleaningScheduleDateTimeLogic.formatTimeApi(value));
  }
}
