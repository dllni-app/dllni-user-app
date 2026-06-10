double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _toStringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

class CleaningWorkerRoomAssignmentRoom {
  const CleaningWorkerRoomAssignmentRoom({
    required this.roomKey,
    required this.roomType,
    required this.roomSize,
  });

  final String roomKey;
  final String roomType;
  final String roomSize;

  factory CleaningWorkerRoomAssignmentRoom.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerRoomAssignmentRoom(
      roomKey: _toStringValue(json['roomKey'] ?? json['room_key']) ?? '',
      roomType: _toStringValue(json['roomType'] ?? json['room_type']) ?? '',
      roomSize: _toStringValue(json['roomSize'] ?? json['room_size']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'roomKey': roomKey,
    'roomType': roomType,
    'roomSize': roomSize,
  };
}

class CleaningWorkerRoomAssignment {
  const CleaningWorkerRoomAssignment({
    required this.workerSlot,
    this.preferredWorkerId,
    this.roomsWeight,
    this.estimatedServiceShareAmount,
    this.rooms = const [],
  });

  final int workerSlot;
  final int? preferredWorkerId;
  final double? roomsWeight;
  final double? estimatedServiceShareAmount;
  final List<CleaningWorkerRoomAssignmentRoom> rooms;

  factory CleaningWorkerRoomAssignment.fromJson(Map<String, dynamic> json) {
    final roomsRaw = json['rooms'];
    final rooms = roomsRaw is List
        ? roomsRaw
              .whereType<Map<String, dynamic>>()
              .map(CleaningWorkerRoomAssignmentRoom.fromJson)
              .toList(growable: false)
        : const <CleaningWorkerRoomAssignmentRoom>[];

    return CleaningWorkerRoomAssignment(
      workerSlot: _toInt(json['workerSlot'] ?? json['worker_slot']) ?? 0,
      preferredWorkerId: _toInt(
        json['preferredWorkerId'] ?? json['preferred_worker_id'],
      ),
      roomsWeight: _toDouble(json['roomsWeight'] ?? json['rooms_weight']),
      estimatedServiceShareAmount: _toDouble(
        json['estimatedServiceShareAmount'] ??
            json['estimated_service_share_amount'],
      ),
      rooms: rooms,
    );
  }

  Map<String, dynamic> toRequestJson() => {
    'workerSlot': workerSlot,
    'preferredWorkerId': preferredWorkerId,
    'rooms': rooms.map((room) => room.toJson()).toList(growable: false),
  };
}

bool workerRoomAssignmentHasRooms(CleaningWorkerRoomAssignment assignment) =>
    assignment.rooms.isNotEmpty;

List<CleaningWorkerRoomAssignment> filterNonEmptyWorkerRoomAssignments(
  List<CleaningWorkerRoomAssignment> assignments,
) {
  return assignments
      .where(workerRoomAssignmentHasRooms)
      .toList(growable: false);
}

List<Map<String, dynamic>> filterNonEmptyWorkerRoomAssignmentMaps(
  List<Map<String, dynamic>> assignments,
) {
  return assignments.where((entry) {
    final rooms = entry['rooms'];
    return rooms is List && rooms.isNotEmpty;
  }).toList(growable: false);
}

List<CleaningWorkerRoomAssignment> parseWorkerRoomAssignments(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(CleaningWorkerRoomAssignment.fromJson)
      .where((assignment) => assignment.workerSlot > 0)
      .toList(growable: false);
}

List<Map<String, dynamic>> workerRoomAssignmentsToRequestJson(
  List<CleaningWorkerRoomAssignment> assignments,
) {
  return filterNonEmptyWorkerRoomAssignments(assignments)
      .map((assignment) => assignment.toRequestJson())
      .toList(growable: false);
}
