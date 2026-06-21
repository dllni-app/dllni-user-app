import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cl_worker_room_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enumerateRoomUnits', () {
    test('includes corridor room keys in API assignment payloads', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );

      final units = enumerateRoomUnits(breakdown);

      expect(units, hasLength(2));
      expect(units.map((unit) => unit.roomKey), {
        'bedroom.small.1',
        'corridor.medium.1',
      });
    });
  });

  group('buildWorkerRoomAssignmentsJson', () {
    test('assigns backend-accepted room keys including corridor', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );
      final units = enumerateRoomUnits(breakdown);

      final assignments = buildWorkerRoomAssignmentsJson(
        slotByRoomKey: {
          'bedroom.small.1': 1,
          'corridor.medium.1': 1,
        },
        units: units,
        assignmentMode: CleaningAssignmentMode.openCount,
      );

      expect(assignments, hasLength(1));
      final rooms = assignments.first['rooms'] as List;
      expect(rooms, hasLength(2));
      expect(
        rooms.map((room) => (room as Map)['roomKey']),
        {'bedroom.small.1', 'corridor.medium.1'},
      );
    });

    test('never returns entries with empty rooms arrays', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        livingRoom: CleaningRoomSizeBucket(small: 0, medium: 0, large: 1),
      );
      final units = enumerateRoomUnits(breakdown);

      final assignments = buildWorkerRoomAssignmentsJson(
        slotByRoomKey: {'living_room.large.1': 1},
        units: units,
        assignmentMode: CleaningAssignmentMode.openCount,
      );

      expect(assignments, hasLength(1));
      expect(assignments.first['workerSlot'], 1);
      expect(
        assignments.every(
          (entry) => (entry['rooms'] as List).isNotEmpty,
        ),
        isTrue,
      );
      expect(
        assignments.any((entry) => entry['workerSlot'] == 4),
        isFalse,
      );
    });
  });
}
