import 'package:flutter/material.dart';

import 'shared_platform_colors.dart';

/// Backward-compatible aliases. New UI uses SharedPlatformColors tokens.
class AppColors {
  const AppColors._();

  static const Color primary = SharedPlatformColors.primary;
  static const Color secondary = SharedPlatformColors.neutral;
  static const Color accent = SharedPlatformColors.cleaning;
  static const Color white = SharedPlatformColors.surface;
  static const Color scaffoldBackgroundColor = SharedPlatformColors.background;
  static const Color filledInputBackgroundColor = Color(0xFFFFFFFF);
  static const Color hintText = SharedPlatformColors.muted;
}
