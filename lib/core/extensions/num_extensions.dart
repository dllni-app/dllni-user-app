import 'package:intl/intl.dart';

extension NumExtensions on num {
  String formatWithComma() {
    return NumberFormat.decimalPattern().format(this);
  }
}
