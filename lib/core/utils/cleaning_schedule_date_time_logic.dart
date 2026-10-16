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

  /// Validate a local appointment against the current local device time.
  /// Recheck on submission because a once-valid selection can expire while
  /// the customer is completing the booking form.
  static String? futureAppointmentError({
    required DateTime date,
    required String time,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final day = dateOnly(date);
    if (day.isBefore(dateOnly(current))) {
      return 'لا يمكن اختيار تاريخ منقضٍ. اختر تاريخًا جديدًا.';
    }

    final match = RegExp(r'^([01]\\d|2[0-3]):([0-5]\\d)(?::[0-5]\\d)?
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
)
        .firstMatch(time.trim());
    if (match == null) {
      return 'يرجى اختيار وقت صحيح للطلب.';
    }

    final appointment = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
    if (!appointment.isAfter(current)) {
      return 'لا يمكن اختيار وقت منقضٍ. اختر موعدًا لاحقًا.';
    }
    return null;
  }

  static DateTime? parseDateApi(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
