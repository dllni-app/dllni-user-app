import '../utils/app_date_time_locale.dart';

extension NumExtensions on num {
  String formatWithComma() {
    return AppDateTimeLocale.decimalPattern().format(this);
  }
}
