import '../../../../core/utils/app_date_time_locale.dart';

const String orderDateTimePattern = 'yyyy-MM-dd hh:mm a';

String formatOrderDateTime(String? value) {
  final rawValue = value?.trim() ?? '';
  if (rawValue.isEmpty) return '-';

  final parsed = DateTime.tryParse(rawValue);
  if (parsed == null) return rawValue;

  return AppDateTimeLocale.dateFormat(
    orderDateTimePattern,
  ).format(parsed.toLocal());
}
