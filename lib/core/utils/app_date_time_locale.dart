import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateTimeLocale {
  const AppDateTimeLocale._();

  static const String languageCode = 'en';
  static const String intlLocale = 'en_US';
  static const Locale locale = Locale(languageCode);

  static DateFormat dateFormat(String pattern) {
    return DateFormat(pattern, intlLocale);
  }

  static NumberFormat decimalPattern() {
    return NumberFormat.decimalPattern(intlLocale);
  }
}
