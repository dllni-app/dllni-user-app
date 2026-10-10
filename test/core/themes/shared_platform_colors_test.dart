import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each business section gets its own contextual palette', () {
    expect(
      SharedPlatformColors.sectionAccent('cleaning'),
      SharedPlatformColors.cleaning,
    );
    expect(
      SharedPlatformColors.sectionAccent('restaurants'),
      SharedPlatformColors.restaurant,
    );
    expect(
      SharedPlatformColors.sectionAccent('store'),
      SharedPlatformColors.supermarket,
    );
    expect(
      SharedPlatformColors.sectionAccent('delivery'),
      SharedPlatformColors.delivery,
    );
    expect(SharedPlatformColors.restaurant, isNot(const Color(0xFFC65324)));
    expect(
      SharedPlatformColors.sectionSoft('restaurant'),
      SharedPlatformColors.restaurantSoft,
    );
  });

  test('semantic colors and primary brand stay consistent across sections', () {
    for (final section in [
      'cleaning',
      'restaurant',
      'supermarket',
      'delivery',
    ]) {
      final scheme = AppTheme.forSection(section).colorScheme;
      expect(scheme.primary, SharedPlatformColors.primary);
      expect(scheme.secondary, SharedPlatformColors.sectionAccent(section));
      expect(
        scheme.onSecondaryContainer,
        SharedPlatformColors.sectionInk(section),
      );
      expect(scheme.error, SharedPlatformColors.danger);
      expect(scheme.onSurface, SharedPlatformColors.ink);
      expect(scheme.onPrimaryContainer, Colors.white);
    }
  });

  test('platform theme matches approved navy, slate, and background', () {
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF172554));
    expect(AppTheme.light.colorScheme.secondary, const Color(0xFF697386));
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFF6F7F9));
  });
}
