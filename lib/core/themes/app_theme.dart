import 'package:flutter/material.dart';

import 'shared_platform_colors.dart';

/// Shared foundations: 8-point rhythm, Cairo, 16-point cards, 52-point CTAs.
/// Business flows/API requests are independent of these presentation themes.
class AppTheme {
  const AppTheme._();

  static final ThemeData light = _build();

  /// Scopes Material controls to a service without changing the global brand.
  static ThemeData forSection(String section) => _build(section: section);

  static ThemeData _build({String? section}) {
    final accent = SharedPlatformColors.sectionAccent(section);
    final soft = SharedPlatformColors.sectionSoft(section);
    final ink = SharedPlatformColors.sectionInk(section);
    final isCleaning =
        SharedPlatformColors.normalizeSection(section) == 'cleaning';
    final scheme =
        ColorScheme.fromSeed(
          seedColor: SharedPlatformColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: SharedPlatformColors.primary,
          onPrimary: Colors.white,
          primaryContainer: section == null
              ? SharedPlatformColors.primary
              : accent,
          onPrimaryContainer: Colors.white,
          secondary: accent,
          onSecondary: isCleaning ? SharedPlatformColors.primary : Colors.white,
          secondaryContainer: soft,
          onSecondaryContainer: ink,
          surface: SharedPlatformColors.surface,
          onSurface: SharedPlatformColors.ink,
          error: SharedPlatformColors.danger,
          onError: Colors.white,
          outline: SharedPlatformColors.border,
        );
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: scheme,
      scaffoldBackgroundColor: SharedPlatformColors.background,
      dividerColor: SharedPlatformColors.border,
      cardColor: SharedPlatformColors.surface,
      splashColor: accent.withValues(alpha: .08),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SharedPlatformColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SharedPlatformColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: SharedPlatformColors.primary,
          side: const BorderSide(color: SharedPlatformColors.border),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SharedPlatformColors.surface,
        hintStyle: const TextStyle(
          color: SharedPlatformColors.muted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: SharedPlatformColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: SharedPlatformColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
      ),
    );
  }
}
