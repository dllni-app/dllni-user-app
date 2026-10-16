import 'package:flutter/material.dart';

IconData iconForSpecialService(String rawName) {
  final name = rawName.trim().toLowerCase();
  if (name.contains('زجاج') || name.contains('نافذ') || name.contains('شباك')) {
    return Icons.window_outlined;
  }
  if (name.contains('أرض') ||
      name.contains('بلاط') ||
      name.contains('سيراميك')) {
    return Icons.grid_on_outlined;
  }
  if (name.contains('سجاد') || name.contains('موكيت')) {
    return Icons.layers_outlined;
  }
  if (name.contains('كنب') ||
      name.contains('أريكة') ||
      name.contains('مفروش')) {
    return Icons.weekend_outlined;
  }
  if (name.contains('مطبخ') ||
      name.contains('دهون') ||
      name.contains('فرن') ||
      name.contains('ثلاج')) {
    return Icons.kitchen_outlined;
  }
  if (name.contains('دهان') ||
      name.contains('طلاء') ||
      name.contains('صيانة')) {
    return Icons.format_paint_outlined;
  }
  if (name.contains('حمام') || name.contains('تعقيم')) {
    return Icons.bathtub_outlined;
  }
  if (name.contains('ستار') || name.contains('ستائ')) {
    return Icons.curtains_outlined;
  }
  return Icons.auto_awesome_outlined;
}
