import 'cleaning_assignment_mode.dart';
import 'cleaning_room_size_breakdown.dart';
import 'cl_worker_room_assignment_result.dart';
class CleaningRoomUnit {
  const CleaningRoomUnit({
    required this.roomKey,
    required this.roomType,
    required this.roomSize,
    required this.displayLabel,
  });

  final String roomKey;
  final String roomType;
  final String roomSize;
  final String displayLabel;

  Map<String, dynamic> toJson() => {
    'roomKey': roomKey,
    'roomType': roomType,
    'roomSize': roomSize,
  };
}

const Map<CleaningRoomType, String> _roomTypeLabelsAr = {
  CleaningRoomType.bedroom: 'غرفة نوم',
  CleaningRoomType.bathroom: 'حمام',
  CleaningRoomType.kitchen: 'مطبخ',
  CleaningRoomType.livingRoom: 'صالون',
  CleaningRoomType.balcony: 'بلكونة',
  CleaningRoomType.corridor: 'موزع',
};

const Map<CleaningRoomSize, String> _roomSizeLabelsAr = {
  CleaningRoomSize.small: 'صغير',
  CleaningRoomSize.medium: 'متوسط',
  CleaningRoomSize.large: 'كبير',
};

List<CleaningRoomUnit> enumerateRoomUnits(CleaningRoomSizeBreakdown breakdown) {
  final units = <CleaningRoomUnit>[];

  for (final roomType in backendSupportedCleaningRoomTypes) {
    final typeLabel = _roomTypeLabelsAr[roomType] ?? roomType.apiKey;
    for (final size in CleaningRoomSize.values) {
      final count = breakdown.countFor(roomType, size);
      final sizeLabel = _roomSizeLabelsAr[size] ?? size.apiValue;
      for (var index = 1; index <= count; index++) {
        units.add(
          CleaningRoomUnit(
            roomKey: '${roomType.apiKey}.${size.apiValue}.$index',
            roomType: roomType.apiKey,
            roomSize: size.apiValue,
            displayLabel: '$typeLabel $index - $sizeLabel',
          ),
        );
      }
    }
  }

  return units;
}

List<Map<String, dynamic>> buildWorkerRoomAssignmentsJson({
  required Map<String, int> slotByRoomKey,
  required List<CleaningRoomUnit> units,
  int? preferredWorkerId,
  CleaningAssignmentMode? assignmentMode,
}) {
  if (units.isEmpty) return const [];

  final isPreferredWorker =
      assignmentMode == CleaningAssignmentMode.preferredWorker &&
      preferredWorkerId != null;

  if (isPreferredWorker) {
    return filterNonEmptyWorkerRoomAssignmentMaps([
      {
        'workerSlot': 1,
        'preferredWorkerId': preferredWorkerId,
        'rooms': units.map((unit) => unit.toJson()).toList(growable: false),
      },
    ]);
  }
  final slotRooms = <int, List<Map<String, dynamic>>>{};
  for (final unit in units) {
    final slot = slotByRoomKey[unit.roomKey];
    if (slot == null || slot < 1) continue;
    slotRooms.putIfAbsent(slot, () => <Map<String, dynamic>>[]).add(unit.toJson());
  }

  if (slotRooms.isEmpty) return const [];

  return filterNonEmptyWorkerRoomAssignmentMaps(
    slotRooms.entries
        .map(
          (entry) => {
            'workerSlot': entry.key,
            'preferredWorkerId': null,
            'rooms': entry.value,
          },
        )
        .toList(growable: false)
      ..sort(
        (a, b) => (a['workerSlot'] as int).compareTo(b['workerSlot'] as int),
      ),
  );
}