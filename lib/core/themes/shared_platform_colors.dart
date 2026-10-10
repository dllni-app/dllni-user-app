import 'package:flutter/material.dart';

/// Alnadha visual foundations (reference: approved Arabic RTL foundations).
///
/// Navy owns primary actions across every section. Section accents are reserved
/// for contextual navigation, selected controls, icons and pale secondary actions.
/// Never use an accent as the only indication of status or as a warning color.
abstract final class SharedPlatformColors {
  // Sampled from the approved design reference.
  static const primary = Color(0xFF172554);
  static const deepNavy = Color(0xFF172554);
  static const neutral = Color(0xFF697386);
  static const neutralSoft = Color(0xFFE9ECF1);
  static const background = Color(0xFFF6F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF182232);
  static const muted = Color(0xFF697386);
  static const subtle = Color(0xFF8B95A5);
  static const border = Color(0xFFE0E5EB);

  // Semantic states must remain distinct from commercial section accents.
  static const success = Color(0xFF168463);
  static const warning = Color(0xFFAB691C);
  static const danger = Color(0xFFC53D47);
  static const dangerSoft = Color(0xFFFCEDEF);

  // Cleaning: accessible dark ink on the reference turquoise.
  static const cleaning = Color(0xFF0CBBC7);
  static const cleaningSoft = Color(0xFFE7F8F9);
  static const cleaningInk = Color(0xFF006E79);

  // Restaurants: berry, deliberately replacing the legacy burnt orange.
  static const restaurant = Color(0xFFA63C66);
  static const restaurantSoft = Color(0xFFFAEAF0);
  static const restaurantInk = Color(0xFF84274D);

  // Supermarket: calmer emerald green.
  static const supermarket = Color(0xFF168A67);
  static const supermarketSoft = Color(0xFFE8F6EF);
  static const supermarketInk = Color(0xFF12694F);

  // Independent delivery tracking.
  static const delivery = Color(0xFF5D62B1);
  static const deliverySoft = Color(0xFFEEEEFA);
  static const deliveryInk = Color(0xFF424891);

  // Compatibility tokens. Avoid introducing new uses in feature screens.
  @Deprecated('Prefer sectionAccent and semantic tokens')
  static const purple = delivery;
  @Deprecated('Use sectionAccent(restaurant) instead')
  static const brandOrange = restaurant;

  static String normalizeSection(String? section) {
    switch ((section ?? '').trim().toLowerCase()) {
      case 'cl':
      case 'cleaning':
      case 'cleaning_orders':
        return 'cleaning';
      case 'rs':
      case 'restaurants':
      case 'restaurant':
      case 'food':
        return 'restaurant';
      case 'sm':
      case 'supermarket':
      case 'store':
      case 'grocery':
        return 'supermarket';
      case 'delivery':
      case 'mandoub':
      case 'courier':
        return 'delivery';
      default:
        return 'platform';
    }
  }

  static Color sectionAccent(String? section) {
    switch (normalizeSection(section)) {
      case 'cleaning':
        return cleaning;
      case 'restaurant':
        return restaurant;
      case 'supermarket':
        return supermarket;
      case 'delivery':
        return delivery;
      default:
        return neutral;
    }
  }

  static Color sectionSoft(String? section) {
    switch (normalizeSection(section)) {
      case 'cleaning':
        return cleaningSoft;
      case 'restaurant':
        return restaurantSoft;
      case 'supermarket':
        return supermarketSoft;
      case 'delivery':
        return deliverySoft;
      default:
        return neutralSoft;
    }
  }

  /// For text/icons on pale section surfaces, never put white on light cyan.
  static Color sectionInk(String? section) {
    switch (normalizeSection(section)) {
      case 'cleaning':
        return cleaningInk;
      case 'restaurant':
        return restaurantInk;
      case 'supermarket':
        return supermarketInk;
      case 'delivery':
        return deliveryInk;
      default:
        return primary;
    }
  }
}
