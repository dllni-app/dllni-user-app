import 'cleaning_room_size_breakdown.dart';
import 'cleaning_type.dart';

class CleaningProgressiveRoomUnit {
  const CleaningProgressiveRoomUnit({
    required this.roomType,
    required this.index,
    required this.size,
    this.cleaningType = CleaningType.regularCleaning,
  });

  final CleaningRoomType roomType;
  final int index;
  final CleaningRoomSize size;
  final CleaningType cleaningType;

  String get key => '${roomType.apiKey}.$index';

  CleaningProgressiveRoomUnit copyWith({
    CleaningRoomSize? size,
    CleaningType? cleaningType,
  }) {
    return CleaningProgressiveRoomUnit(
      roomType: roomType,
      index: index,
      size: size ?? this.size,
      cleaningType: cleaningType ?? this.cleaningType,
    );
  }
}

class CleaningProgressiveRoomState {
  const CleaningProgressiveRoomState({
    this.counts = const <CleaningRoomType, int>{},
    this.units = const <CleaningProgressiveRoomUnit>[],
  });

  final Map<CleaningRoomType, int> counts;
  final List<CleaningProgressiveRoomUnit> units;

  int countFor(CleaningRoomType roomType) => counts[roomType] ?? 0;

  int get totalUnits => counts.values.fold<int>(0, (sum, count) => sum + count);

  /// The quote request's `propertyDetails.rooms` is capped at 30 by Laravel.
  /// Balconies are extra spaces, not a replacement for a room to clean.
  static const int maxBaseRooms = 30;

  int get totalBaseRooms => allCleaningRoomTypes
      .where((type) => type != CleaningRoomType.balcony)
      .fold<int>(0, (sum, type) => sum + countFor(type));

  bool get hasAnyRoom => totalBaseRooms > 0;

  int maxCountFor(CleaningRoomType roomType) {
    // Keep individual counters within the backend's legacy room limits too.
    final perTypeLimit = switch (roomType) {
      CleaningRoomType.bedroom ||
      CleaningRoomType.bathroom ||
      CleaningRoomType.kitchen ||
      CleaningRoomType.balcony ||
      CleaningRoomType.shed => 20,
      CleaningRoomType.livingRoom || CleaningRoomType.corridor => maxBaseRooms,
    };
    if (roomType == CleaningRoomType.balcony) return perTypeLimit;
    final available = maxBaseRooms - (totalBaseRooms - countFor(roomType));
    return available < 0
        ? 0
        : (available < perTypeLimit ? available : perTypeLimit);
  }

  CleaningProgressiveRoomState setCount(CleaningRoomType roomType, int value) {
    final max = maxCountFor(roomType);
    final safeValue = value < 0 ? 0 : (value > max ? max : value);
    final nextCounts = <CleaningRoomType, int>{...counts, roomType: safeValue};
    final previousByKey = <String, CleaningProgressiveRoomUnit>{
      for (final unit in units) unit.key: unit,
    };
    final nextUnits = <CleaningProgressiveRoomUnit>[];

    for (final type in allCleaningRoomTypes) {
      final count = nextCounts[type] ?? 0;
      for (var index = 1; index <= count; index++) {
        final key = '${type.apiKey}.$index';
        nextUnits.add(
          previousByKey[key] ??
              CleaningProgressiveRoomUnit(
                roomType: type,
                index: index,
                size: CleaningRoomSize.medium,
              ),
        );
      }
    }

    return CleaningProgressiveRoomState(
      counts: Map.unmodifiable(nextCounts),
      units: List.unmodifiable(nextUnits),
    );
  }

  CleaningProgressiveRoomState setUnitSize(
    CleaningRoomType roomType,
    int index,
    CleaningRoomSize size,
  ) {
    final nextUnits = units
        .map(
          (unit) => unit.roomType == roomType && unit.index == index
              ? unit.copyWith(size: size)
              : unit,
        )
        .toList(growable: false);
    return CleaningProgressiveRoomState(
      counts: counts,
      units: List.unmodifiable(nextUnits),
    );
  }

  CleaningProgressiveRoomState setUnitCleaningType(
    CleaningRoomType roomType,
    int index,
    CleaningType cleaningType,
  ) {
    final updated = units
        .map(
          (unit) => unit.roomType == roomType && unit.index == index
              ? unit.copyWith(cleaningType: cleaningType)
              : unit,
        )
        .toList(growable: false);
    return CleaningProgressiveRoomState(
      counts: counts,
      units: List.unmodifiable(updated),
    );
  }

  CleaningProgressiveRoomState setAllCleaningTypes(CleaningType cleaningType) {
    return CleaningProgressiveRoomState(
      counts: counts,
      units: List.unmodifiable(
        units.map((unit) => unit.copyWith(cleaningType: cleaningType)),
      ),
    );
  }

  /// Match the room keys used by worker assignment and backend pricing.
  Map<String, String> get roomCleaningModes {
    final values = <String, String>{};
    for (final type in backendAcceptedRoomSizeBreakdownTypes) {
      for (final size in CleaningRoomSize.values) {
        var index = 0;
        for (final unit in units) {
          if (unit.roomType != type || unit.size != size) continue;
          index++;
          values['${type.apiKey}.${size.apiValue}.$index'] =
              unit.cleaningType.cleaningModeValue;
        }
      }
    }
    return Map.unmodifiable(values);
  }

  /// Applies one chosen size to every room of the same type. Other types stay
  /// untouched, and callers may still override individual units afterwards.
  CleaningProgressiveRoomState setAllUnitSizes(
    CleaningRoomType roomType,
    CleaningRoomSize size,
  ) {
    final nextUnits = units
        .map(
          (unit) =>
              unit.roomType == roomType ? unit.copyWith(size: size) : unit,
        )
        .toList(growable: false);
    return CleaningProgressiveRoomState(
      counts: counts,
      units: List.unmodifiable(nextUnits),
    );
  }

  CleaningRoomSizeBreakdown toBreakdown() {
    var breakdown = const CleaningRoomSizeBreakdown();
    for (final unit in units) {
      final current = breakdown.countFor(unit.roomType, unit.size);
      breakdown = breakdown.setCount(unit.roomType, unit.size, current + 1);
    }
    return breakdown;
  }

  factory CleaningProgressiveRoomState.fromBreakdown(
    CleaningRoomSizeBreakdown breakdown,
  ) {
    var state = const CleaningProgressiveRoomState();
    for (final roomType in allCleaningRoomTypes) {
      final count = breakdown.totalForType(roomType);
      state = state.setCount(roomType, count);
    }

    final unitsByType = <CleaningRoomType, List<CleaningProgressiveRoomUnit>>{};
    for (final unit in state.units) {
      unitsByType.putIfAbsent(unit.roomType, () => []).add(unit);
    }

    final sizedUnits = <CleaningProgressiveRoomUnit>[];
    for (final roomType in allCleaningRoomTypes) {
      final generated = unitsByType[roomType] ?? const [];
      var cursor = 0;
      for (final size in CleaningRoomSize.values) {
        final sizeCount = breakdown.countFor(roomType, size);
        for (var i = 0; i < sizeCount && cursor < generated.length; i++) {
          sizedUnits.add(generated[cursor].copyWith(size: size));
          cursor++;
        }
      }
    }

    return CleaningProgressiveRoomState(
      counts: state.counts,
      units: List.unmodifiable(sizedUnits),
    );
  }
}
