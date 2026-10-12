import 'package:flutter/material.dart';
import '../../themes/shared_platform_colors.dart';

/// V6 UX Refined visual contract. Backend status/pricing never lives here.
abstract final class AlnadhaTokens {
  static const Color primary = SharedPlatformColors.primary;
  static const Color background = SharedPlatformColors.background;
  static const Color surface = SharedPlatformColors.surface;
  static const Color ink = SharedPlatformColors.ink;
  static const Color muted = SharedPlatformColors.muted;
  static const Color border = SharedPlatformColors.border;
  static const Color success = SharedPlatformColors.success;
  static const Color warning = SharedPlatformColors.warning;
  static const Color danger = SharedPlatformColors.danger;

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double cardRadius = 16;
  static const double buttonRadius = 16;
  static const double controlHeight = 52;
  static const double minimumTouchSize = 48;

  static const TextStyle title = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.4,
    color: ink,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.4,
    color: ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.55,
    color: ink,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: muted,
  );
  static const TextStyle button = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );
}

enum AppSection { platform, cleaning, restaurant, supermarket, delivery }

extension AppSectionColors on AppSection {
  String get backendKey => switch (this) {
    AppSection.platform => 'platform',
    AppSection.cleaning => 'cleaning',
    AppSection.restaurant => 'restaurant',
    AppSection.supermarket => 'supermarket',
    AppSection.delivery => 'delivery',
  };
  Color get accent => SharedPlatformColors.sectionAccent(backendKey);
  Color get soft => SharedPlatformColors.sectionSoft(backendKey);
  Color get ink => SharedPlatformColors.sectionInk(backendKey);
}
