import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_time_locale.dart';

class AppPickers {
  static Future<String> showAppTimePicker({
    required BuildContext context,
    DateTime? minimumTime,
  }) async {
    final TimeOfDay? res = await showTimePicker(
      context: context,
      initialTime: minimumTime != null
          ? TimeOfDay.fromDateTime(minimumTime)
          : TimeOfDay.now(),
      builder: (context, child) => Localizations.override(
        context: context,
        locale: AppDateTimeLocale.locale,
        child: Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        ),
      ),
    );

    if (res == null) return '';

    final now = DateTime.now();

    DateTime selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      res.hour,
      res.minute,
    );

    selectedTime = _roundToHalfHour(selectedTime);

    if (minimumTime != null) {
      final roundedMinimum = _roundToHalfHour(minimumTime);

      if (selectedTime.isBefore(roundedMinimum)) {
        selectedTime = roundedMinimum;
      }
    }

    return AppDateTimeLocale.dateFormat('HH:mm').format(selectedTime);
  }

  static DateTime _roundToHalfHour(DateTime dateTime) {
    if (dateTime.minute < 15) {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        0,
      );
    }

    if (dateTime.minute < 45) {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        30,
      );
    }

    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour + 1,
      0,
    );
  }

  static Future<String> showAppDatePicker({
    required BuildContext context,
    DateTime? startDate,
  }) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final requestedStartDate = startDate == null
        ? todayDate
        : DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final firstSelectableDate =
    requestedStartDate.difference(todayDate).inDays <= 1
        ? todayDate
        : requestedStartDate;

    final DateTime? res = await showDatePicker(
      context: context,
      locale: AppDateTimeLocale.locale,
      initialDate: firstSelectableDate,
      firstDate: firstSelectableDate,
      lastDate: todayDate.add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (res == null) return '';

    return AppDateTimeLocale.dateFormat('yyyy-MM-dd').format(res);
  }

}
