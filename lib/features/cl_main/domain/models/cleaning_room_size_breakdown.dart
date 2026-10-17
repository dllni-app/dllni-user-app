/// Stable room identity; Filament may add codes that are unknown at build time.
/// The seven legacy constants are preserved for existing screens and drafts.
final class CleaningRoomType {
  const CleaningRoomType._(this.apiKey);

  final String apiKey;
  static const bedroom = CleaningRoomType._('bedroom');
  static const bathroom = CleaningRoomType._('bathroom');
  static const kitchen = CleaningRoomType._('kitchen');
  static const livingRoom = CleaningRoomType._('living_room');
  static const balcony = CleaningRoomType._('balcony');
  static const corridor = CleaningRoomType._('corridor');
  static const shed = CleaningRoomType._('shed');
  static const values = <CleaningRoomType>[
    bedroom,
    bathroom,
    kitchen,
    livingRoom,
    balcony,
    corridor,
    shed,
  ];

  static final _validCode = RegExp(r'^[a-z][a-z0-9_]*$');

  static CleaningRoomType fromCode(String code) {
    if (!_validCode.hasMatch(code)) {
      throw ArgumentError.value(code, 'code', 'Invalid room catalog code');
    }
    for (final existing in values) {
      if (existing.apiKey == code) return existing;
    }
    return CleaningRoomType._(code);
  }

  @override
  bool operator ==(Object other) =>
      other is CleaningRoomType && other.apiKey == apiKey;

  @override
  int get hashCode => apiKey.hashCode;

  @override
  String toString() => apiKey;
}

/// Original room types used when the catalog cannot be fetched. Additional
/// valid codes come from the server's active Filament catalog at runtime.
const backendAcceptedRoomSizeBreakdownTypes = <CleaningRoomType>[
  CleaningRoomType.bedroom,
  CleaningRoomType.bathroom,
  CleaningRoomType.kitchen,
  CleaningRoomType.livingRoom,
  CleaningRoomType.balcony,
  CleaningRoomType.corridor,
  CleaningRoomType.shed,
];

/// All room types supported in the local UI.
const allCleaningRoomTypes = backendAcceptedRoomSizeBreakdownTypes;

enum CleaningRoomSize { small, medium, large }

extension CleaningRoomSizeX on CleaningRoomSize {
  String get apiValue => name;
}

class CleaningRoomSizeBucket {
  const CleaningRoomSizeBucket({
    this.small = 0,
    this.medium = 0,
    this.large = 0,
  });

  final int small;
  final int medium;
  final int large;

  int get total => small + medium + large;

  int getCount(CleaningRoomSize size) {
    switch (size) {
      case CleaningRoomSize.small:
        return small;
      case CleaningRoomSize.medium:
        return medium;
      case CleaningRoomSize.large:
        return large;
    }
  }

  CleaningRoomSizeBucket copyWith({int? small, int? medium, int? large}) {
    return CleaningRoomSizeBucket(
      small: _sanitizeCount(small ?? this.small),
      medium: _sanitizeCount(medium ?? this.medium),
      large: _sanitizeCount(large ?? this.large),
    );
  }

  Map<String, dynamic> toJson() => {
    'small': small,
    'medium': medium,
    'large': large,
  };

  static int _sanitizeCount(int value) => value < 0 ? 0 : value;
}

class CleaningRoomSizeBreakdown {
  const CleaningRoomSizeBreakdown({
    this.bedroom = const CleaningRoomSizeBucket(),
    this.bathroom = const CleaningRoomSizeBucket(),
    this.kitchen = const CleaningRoomSizeBucket(),
    this.livingRoom = const CleaningRoomSizeBucket(),
    this.balcony = const CleaningRoomSizeBucket(),
    this.corridor = const CleaningRoomSizeBucket(),
    this.shed = const CleaningRoomSizeBucket(),
    this.extra = const <String, CleaningRoomSizeBucket>{},
  });

  final CleaningRoomSizeBucket bedroom;
  final CleaningRoomSizeBucket bathroom;
  final CleaningRoomSizeBucket kitchen;
  final CleaningRoomSizeBucket livingRoom;
  final CleaningRoomSizeBucket balcony;
  final CleaningRoomSizeBucket corridor;
  final CleaningRoomSizeBucket shed;
  final Map<String, CleaningRoomSizeBucket> extra;

  Iterable<CleaningRoomType> get roomTypes => [
    ...backendAcceptedRoomSizeBreakdownTypes,
    ...extra.keys.map(CleaningRoomType.fromCode),
  ];

  int get totalRooms =>
      bedroom.total +
      bathroom.total +
      kitchen.total +
      livingRoom.total +
      corridor.total +
      shed.total +
      extra.values.fold<int>(0, (sum, bucket) => sum + bucket.total);

  /// Sum of all room units including balconies (max worker count cap).
  int get totalUnits => totalRooms + balcony.total;

  bool get hasAnyRoom => totalRooms > 0;

  int get legacyBedroomsCount => bedroom.total; //bedRooms

  int get legacyRoomsCount => totalRooms; //all

  int get legacyBathroomsCount => bathroom.total;

  int get legacyBalconiesCount => balcony.total;
  int get legacyCorridorCount => corridor.total;
  int get legacyShedsCount => shed.total;

  String get legacyLivingRoomSize {
    if (livingRoom.large > 0) return CleaningRoomSize.large.apiValue;
    if (livingRoom.medium > 0) return CleaningRoomSize.medium.apiValue;
    return CleaningRoomSize.small.apiValue;
  }

  CleaningRoomSizeBucket bucketFor(CleaningRoomType roomType) {
    switch (roomType) {
      case CleaningRoomType.bedroom:
        return bedroom;
      case CleaningRoomType.bathroom:
        return bathroom;
      case CleaningRoomType.kitchen:
        return kitchen;
      case CleaningRoomType.livingRoom:
        return livingRoom;
      case CleaningRoomType.balcony:
        return balcony;
      case CleaningRoomType.corridor:
        return corridor;
      case CleaningRoomType.shed:
        return shed;
      default:
        return extra[roomType.apiKey] ?? const CleaningRoomSizeBucket();
    }
  }

  int totalForType(CleaningRoomType roomType) => bucketFor(roomType).total;

  int countFor(CleaningRoomType roomType, CleaningRoomSize size) {
    return bucketFor(roomType).getCount(size);
  }

  CleaningRoomSizeBreakdown setCount(
    CleaningRoomType roomType,
    CleaningRoomSize size,
    int value,
  ) {
    final bucket = bucketFor(roomType);
    final safeValue = value < 0 ? 0 : value;
    final updatedBucket = switch (size) {
      CleaningRoomSize.small => bucket.copyWith(small: safeValue),
      CleaningRoomSize.medium => bucket.copyWith(medium: safeValue),
      CleaningRoomSize.large => bucket.copyWith(large: safeValue),
    };
    return copyWithRoomType(roomType, updatedBucket);
  }

  CleaningRoomSizeBreakdown copyWithRoomType(
    CleaningRoomType roomType,
    CleaningRoomSizeBucket bucket,
  ) {
    if (!allCleaningRoomTypes.contains(roomType)) {
      return CleaningRoomSizeBreakdown(
        bedroom: bedroom,
        bathroom: bathroom,
        kitchen: kitchen,
        livingRoom: livingRoom,
        balcony: balcony,
        corridor: corridor,
        shed: shed,
        extra: {...extra, roomType.apiKey: bucket},
      );
    }
    switch (roomType) {
      case CleaningRoomType.bedroom:
        return CleaningRoomSizeBreakdown(
          bedroom: bucket,
          extra: extra,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
          shed: shed,
        );
      case CleaningRoomType.bathroom:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bucket,
          extra: extra,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
          shed: shed,
        );
      case CleaningRoomType.kitchen:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: bucket,
          extra: extra,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
          shed: shed,
        );
      case CleaningRoomType.livingRoom:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: bucket,
          extra: extra,
          balcony: balcony,
          corridor: corridor,
          shed: shed,
        );
      case CleaningRoomType.balcony:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: bucket,
          extra: extra,
          corridor: corridor,
          shed: shed,
        );
      case CleaningRoomType.corridor:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: bucket,
          extra: extra,
          shed: shed,
        );
      case CleaningRoomType.shed:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
          shed: bucket,
          extra: extra,
        );
      default:
        throw StateError('Unexpected room type: ${roomType.apiKey}');
    }
  }

  /// Serializes only backend-accepted room types with total > 0 for API payloads.
  Map<String, dynamic> toBackendJson() {
    final json = <String, dynamic>{};
    for (final roomType in roomTypes) {
      final bucket = bucketFor(roomType);
      if (bucket.total > 0) {
        json[roomType.apiKey] = bucket.toJson();
      }
    }
    return json;
  }

  Map<String, dynamic> toJson() => toBackendJson();
}
