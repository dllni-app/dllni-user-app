import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppPickers {
  static Future<String> showAppTimePicker({required BuildContext context}) async {
    final TimeOfDay? res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor, onSurface: Colors.black),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );

    if (res == null) return '';

    final now = DateTime.now();
    DateTime selectedTime = DateTime(now.year, now.month, now.day, res.hour, res.minute);

    final minute = selectedTime.minute;
    if (minute < 15) {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour, 0);
    } else if (minute < 45) {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour, 30);
    } else {
      selectedTime = DateTime(now.year, now.month, now.day, res.hour + 1, 0);
    }

    return DateFormat('HH:mm', 'en').format(selectedTime);
  }

  static Future<String> showAppDatePicker({required BuildContext context, DateTime? startDate}) async {
    final DateTime? res = await showDatePicker(
      context: context,
      locale: const Locale('en'),
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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

    return DateFormat('yyyy-MM-dd', 'en').format(res);
  }
}
