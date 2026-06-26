import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_time_locale.dart';

class AppPickers {
  static Future<String> showAppTimePicker({
    required BuildContext context,
  }) async {
    final TimeOfDay? res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Localizations.override(
        context: context,
        locale: AppDateTimeLocale.locale,
        child: Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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

    final minute = selectedTime.minute;
    if (minute < 15) {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour, 0);
    } else if (minute < 45) {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour, 30);
    } else {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour + 1, 0);
    }

    return AppDateTimeLocale.dateFormat('HH:mm').format(selectedTime);
  }

  static Future<String> showAppDatePicker({
    required BuildContext context,
    DateTime? startDate,
  }) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final requestedStartDate = startDate == null
        ? todayDate
        : DateTime(startDate.year, startDate.month, startDate.day);

    // Cleaning booking screens previously passed tomorrow to the shared picker,
    // which disabled same-day bookings even though the backend accepts
    // scheduledDate >= today. When the requested start date is only near-future,
    // normalize it to today so the current date is selectable and active.
    final firstSelectableDate = requestedStartDate.difference(todayDate).inDays <= 1
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
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );

    if (res == null) return '';

    return AppDateTimeLocale.dateFormat('yyyy-MM-dd').format(res);
  }
}
