import '../../domain/models/cleaning_room_size_breakdown.dart';

/// Room catalog supplied by the backend and managed in the Filament panel.
///
/// A stable [code] is used in booking payloads, so icon/name updates do not
/// accidentally change the meaning of a saved booking.
class CleaningRoomCatalogItem {
  const CleaningRoomCatalogItem({
    required this.code,
    required this.name,
    required this.iconKey,
    required this.active,
    required this.sortOrder,
    required this.suggestedMinutesBySize,
    this.regularDescription = '',
    this.deepDescription = '',
  });

  final String code;
  final String name;
  final String iconKey;
  final bool active;
  final int sortOrder;
  final Map<String, dynamic> suggestedMinutesBySize;

  /// Exact cleaning scope authored in Filament for this type of room.
  final String regularDescription;
  final String deepDescription;

  double suggestedHours(String size, String mode) {
    final values = suggestedMinutesBySize[size];
    if (values is! Map) return mode == 'deep' ? 1 : 0.5;
    final minutes = values[mode == 'deep' ? 'deepMinutes' : 'regularMinutes'];
    return minutes is num && minutes > 0
        ? double.parse((minutes / 60).toStringAsFixed(2))
        : (mode == 'deep' ? 1 : 0.5);
  }

  factory CleaningRoomCatalogItem.fromJson(Map<String, dynamic> json) {
    return CleaningRoomCatalogItem(
      code: (json['code'] ?? json['key'] ?? '').toString(),
      name: (json['name'] ?? json['nameAr'] ?? json['name_ar'] ?? '')
          .toString(),
      iconKey: (json['iconKey'] ?? json['icon_key'] ?? '').toString(),
      regularDescription:
          (json['regularDescription'] ?? json['regular_description'] ?? '')
              .toString(),
      deepDescription:
          (json['deepDescription'] ?? json['deep_description'] ?? '')
              .toString(),
      active: (json['isActive'] ?? json['is_active'] ?? true) != false,
      sortOrder:
          (json['sortOrder'] ?? json['sort_order'] as num?)?.toInt() ?? 0,
      suggestedMinutesBySize:
          (json['suggestedMinutesBySize'] ?? json['suggested_minutes_by_size'])
              is Map
          ? Map<String, dynamic>.from(
              (json['suggestedMinutesBySize'] ??
                      json['suggested_minutes_by_size'])
                  as Map,
            )
          : const {},
    );
  }
}

List<CleaningRoomCatalogItem> parseCleaningRoomCatalog(dynamic body) {
  dynamic data = body;
  if (data is Map) {
    data =
        data['data'] ??
        data['rooms'] ??
        data['roomTypes'] ??
        data['room_types'] ??
        data;
  }
  if (data is Map) {
    data = data['roomTypes'] ?? data['room_types'] ?? data['rooms'];
  }
  if (data is! List) return const [];

  final catalog = <CleaningRoomCatalogItem>[];
  for (final entry in data) {
    if (entry is! Map) continue;
    final room = CleaningRoomCatalogItem.fromJson(
      Map<String, dynamic>.from(entry),
    );
    if (room.code.isNotEmpty) catalog.add(room);
  }
  // The API already returns rows in Filament order. Sort only when explicit
  // priorities are supplied; equal or missing priorities retain server order.
  if (catalog.any((room) => room.sortOrder != 0)) {
    catalog.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  return catalog;
}

/// Active codes can be selected for a new booking; selections in an open draft
/// remain visible even if an administrator has since deactivated their code.
List<CleaningRoomType> selectableRoomTypes(
  List<CleaningRoomCatalogItem> catalog, {
  Iterable<CleaningRoomType> selected = const [],
}) {
  final types = <CleaningRoomType>[];
  for (final item in catalog) {
    if (!item.active || !CleaningRoomType.isValidCode(item.code)) {
      continue;
    }
    final type = CleaningRoomType.fromCode(item.code);
    if (!types.contains(type)) types.add(type);
  }
  for (final type in selected) {
    if (!types.contains(type)) types.add(type);
  }
  return List.unmodifiable(types);
}
