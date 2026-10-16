import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_time_locale.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';

/// Cleaning pickers show Arabic UI but always return English canonical values
/// (`yyyy-MM-dd`, `HH:mm`) for business logic and API payloads.
class AppPickers {
  static const Locale _pickerUiLocale = Locale('ar');

  static Future<String> showAppTimePicker({
    required BuildContext context,
    DateTime? minimumTime,
    DateTime? scheduledDate,
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

    final timeLabel = AppDateTimeLocale.dateFormat('HH:mm').format(selectedTime);
    String? error;
    if (selectedTime.day != now.day || selectedTime.month != now.month) {
      error = 'اختر وقتًا قبل منتصف الليل، أو غيّر تاريخ الحجز.';
    } else if (minimumTime != null && selectedTime.isBefore(minimumTime)) {
      error = 'هذا الوقت انقضى أو يسبق الحد المسموح. اختر وقتًا لاحقًا.';
    } else if (scheduledDate != null) {
      error = CleaningScheduleDateTimeLogic.futureAppointmentError(
        date: scheduledDate,
        time: timeLabel,
      );
    }
    if (error != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return '';
    }

    return timeLabel;
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

    // Never permit expired dates, and respect a caller's stricter startDate.
    final firstSelectableDate = requestedStartDate.isBefore(todayDate)
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
