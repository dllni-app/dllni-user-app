extension DateTimeExtensions on DateTime {
  String get format =>
      "${day.toString().padLeft(2, '0')} - ${month.toString().padLeft(2, '0')} - $year";
}
