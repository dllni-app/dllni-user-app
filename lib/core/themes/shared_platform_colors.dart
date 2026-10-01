import 'package:flutter/material.dart';

abstract final class SharedPlatformColors {
  static const primary = Color(0xFF1E2A78);
  static const deepNavy = Color(0xFF172554);
  static const purple = Color(0xFF6C63FF);
  static const brandOrange = Color(0xFFFF7A00);

  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF667085);
  static const subtle = Color(0xFF98A2B3);
  static const border = Color(0xFFE4E7EC);

  static const success = Color(0xFF138A62);
  static const warning = Color(0xFFB54708);
  static const danger = Color(0xFFD92D20);

  static const cleaning = Color(0xFF12B8C4);
  static const cleaningSoft = Color(0xFFE9F9FA);
  static const restaurant = Color(0xFFC65324);
  static const restaurantSoft = Color(0xFFFFF0E8);
  static const supermarket = Color(0xFF138A62);
  static const supermarketSoft = Color(0xFFEAF6F1);

  static Color sectionAccent(String? section) {
    switch ((section ?? '').toLowerCase()) {
      case 'cleaning':
        return cleaning;
      case 'restaurant':
        return restaurant;
      case 'supermarket':
      case 'store':
        return supermarket;
      default:
        return primary;
    }
  }

  static Color sectionSoft(String? section) {
    switch ((section ?? '').toLowerCase()) {
      case 'cleaning':
        return cleaningSoft;
      case 'restaurant':
        return restaurantSoft;
      case 'supermarket':
      case 'store':
        return supermarketSoft;
      default:
        return const Color(0xFFEEF0FA);
    }
  }
}
