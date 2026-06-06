enum CleaningRoomType {
  bedroom,
  bathroom,
  kitchen,
  livingRoom,
  balcony,
  corridor,
}

extension CleaningRoomTypeX on CleaningRoomType {
  String get apiKey {
    switch (this) {
      case CleaningRoomType.bedroom:
        return 'bedroom';
      case CleaningRoomType.bathroom:
        return 'bathroom';
      case CleaningRoomType.kitchen:
        return 'kitchen';
      case CleaningRoomType.livingRoom:
        return 'living_room';
      case CleaningRoomType.balcony:
        return 'balcony';
      case CleaningRoomType.corridor:
        return 'corridor';
    }
  }
}

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
  });

  final CleaningRoomSizeBucket bedroom;
  final CleaningRoomSizeBucket bathroom;
  final CleaningRoomSizeBucket kitchen;
  final CleaningRoomSizeBucket livingRoom;
  final CleaningRoomSizeBucket balcony;
  final CleaningRoomSizeBucket corridor;

  int get totalRooms =>
      bedroom.total +
      bathroom.total +
      kitchen.total +
      livingRoom.total +
      corridor.total;

  /// Sum of all room units including balconies (max worker count cap).
  int get totalUnits => totalRooms + balcony.total;

  bool get hasAnyRoom => totalRooms > 0;

  int get legacyBedroomsCount => totalRooms;

  int get legacyRoomsCount => bedroom.total;

  int get legacyBathroomsCount => bathroom.total;

  int get legacyBalconiesCount => balcony.total;

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
    switch (roomType) {
      case CleaningRoomType.bedroom:
        return CleaningRoomSizeBreakdown(
          bedroom: bucket,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
        );
      case CleaningRoomType.bathroom:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bucket,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
        );
      case CleaningRoomType.kitchen:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: bucket,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: corridor,
        );
      case CleaningRoomType.livingRoom:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: bucket,
          balcony: balcony,
          corridor: corridor,
        );
      case CleaningRoomType.balcony:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: bucket,
          corridor: corridor,
        );
      case CleaningRoomType.corridor:
        return CleaningRoomSizeBreakdown(
          bedroom: bedroom,
          bathroom: bathroom,
          kitchen: kitchen,
          livingRoom: livingRoom,
          balcony: balcony,
          corridor: bucket,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      for (final roomType in CleaningRoomType.values)
        roomType.apiKey: bucketFor(roomType).toJson(),
    };
  }
}
