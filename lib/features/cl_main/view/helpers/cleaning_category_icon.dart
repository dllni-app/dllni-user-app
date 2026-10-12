import 'package:flutter/material.dart';

/// Only known server identifiers map to bundled icons. Unknown values use a
/// neutral icon and never become executable code or external image requests.
IconData cleaningCategoryIcon(String? key, {bool occasion = false}) {
  return switch (key?.trim().toLowerCase()) {
    'villa' => Icons.villa_outlined,
    'office' => Icons.business_outlined,
    'apartment' => Icons.apartment_outlined,
    'studio' => Icons.weekend_outlined,
    'family_dinner' => Icons.dinner_dining_outlined,
    'birthday' || 'birthday_party' => Icons.cake_outlined,
    'large_gathering' => Icons.groups_2_outlined,
    'funeral' || 'condolences' => Icons.volunteer_activism_outlined,
    _ => occasion ? Icons.celebration_outlined : Icons.home_outlined,
  };
}
