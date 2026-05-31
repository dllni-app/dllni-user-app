import '../../../../core/utils/app_date_time_locale.dart';

const String cleaningSecurityCodeDateTimePattern = 'yy-MM-dd HH:mm a';

String formatCleaningSecurityCodeDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw.trim();
  return AppDateTimeLocale.dateFormat(
    cleaningSecurityCodeDateTimePattern,
  ).format(parsed.toLocal());
}

String formatCleaningSecurityCodeDateTimeFromDateTime(DateTime? value) {
  if (value == null) return '';
  return AppDateTimeLocale.dateFormat(
    cleaningSecurityCodeDateTimePattern,
  ).format(value.toLocal());
}

String formatCleaningBookingLabel({int? bookingId, String? bookingNumber}) {
  final number = bookingNumber?.trim();
  if (number != null && number.isNotEmpty) {
    return number;
  }
  if (bookingId != null) {
    return '#$bookingId';
  }
  return '-';
}
