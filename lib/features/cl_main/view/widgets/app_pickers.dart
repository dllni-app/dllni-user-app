import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_time_locale.dart';

/// Cleaning pickers show Arabic UI but always return English canonical values
/// (`yyyy-MM-dd`, `HH:mm`) for business logic and API payloads.
class AppPickers {
  static const Locale _pickerUiLocale = Locale('ar');

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
        locale: _pickerUiLocale,
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
    DateTime? initialDate,
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

    final lastSelectableDate = todayDate.add(const Duration(days: 365 * 5));

    final requestedInitialDate = initialDate == null
        ? requestedStartDate
        : DateTime(
            initialDate.year,
            initialDate.month,
            initialDate.day,
          );

    final clampedInitialDate = requestedInitialDate.isBefore(firstSelectableDate)
        ? firstSelectableDate
        : requestedInitialDate.isAfter(lastSelectableDate)
            ? lastSelectableDate
            : requestedInitialDate;

    final DateTime? res = await showDatePicker(
      context: context,
      locale: _pickerUiLocale,
      initialDate: clampedInitialDate,
      firstDate: firstSelectableDate,
      lastDate: lastSelectableDate,
      builder: (context, child) => Localizations.override(
        context: context,
        locale: _pickerUiLocale,
        child: Theme(
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
      ),
    );

    if (res == null) return '';

    return AppDateTimeLocale.dateFormat('yyyy-MM-dd').format(res);
  }
}
