import 'package:flutter/material.dart';

import '../../domain/models/cleaning_room_size_breakdown.dart';

/// A string supplied by Filament is a semantic key, not an IconData codepoint.
/// Never render a missing icon as blank: unknown keys have a visible fallback.
IconData cleaningRoomCatalogIcon(CleaningRoomType type, {String? iconKey}) {
  final key = iconKey?.trim().toLowerCase().replaceAll('-', '_');
  final configured = switch (key) {
    'bed' ||
    'bedroom' ||
    'bedroom_parent_outlined' => Icons.bedroom_parent_outlined,
    'bath' || 'bathroom' || 'bathtub' || 'toilet' => Icons.bathtub_outlined,
    'kitchen' || 'soup_kitchen' => Icons.soup_kitchen_outlined,
    'sofa' || 'living_room' || 'chair' => Icons.chair_alt_outlined,
    'balcony' => Icons.balcony_outlined,
    'corridor' || 'door' || 'meeting_room' => Icons.meeting_room_outlined,
    'shed' || 'garage' || 'storage' => Icons.garage_outlined,
    'study' || 'office' || 'desk' => Icons.desktop_windows_outlined,
    'garden' || 'yard' => Icons.park_outlined,
    'dining_room' || 'dining' => Icons.dining_outlined,
    'laundry' || 'washing_machine' => Icons.local_laundry_service_outlined,
    'stairs' || 'staircase' => Icons.stairs_outlined,
    _ => null,
  };
  if (configured != null) return configured;
  return switch (type) {
    CleaningRoomType.bedroom => Icons.bedroom_parent_outlined,
    CleaningRoomType.bathroom => Icons.bathtub_outlined,
    CleaningRoomType.kitchen => Icons.soup_kitchen_outlined,
    CleaningRoomType.livingRoom => Icons.chair_alt_outlined,
    CleaningRoomType.balcony => Icons.balcony_outlined,
    CleaningRoomType.corridor => Icons.meeting_room_outlined,
    CleaningRoomType.shed => Icons.garage_outlined,
    _ => Icons.home_outlined,
  };
}
