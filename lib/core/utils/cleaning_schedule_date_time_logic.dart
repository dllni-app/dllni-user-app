import 'app_date_time_locale.dart';

/// English canonical values for cleaning schedule logic, API payloads, and
/// comparisons. Do not use Arabic strings from [CleaningDateTimeUiFormat] here.
class CleaningScheduleDateTimeLogic {
  const CleaningScheduleDateTimeLogic._();

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime tomorrowDate() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day + 1);
  }

  static String formatDateApi(DateTime date) {
    return AppDateTimeLocale.dateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTimeApi(DateTime time) {
    return AppDateTimeLocale.dateFormat('HH:mm').format(time);
  }

  static String normalizeTimeHhMm(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDateApi(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
