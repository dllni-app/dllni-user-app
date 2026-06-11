import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cl_worker_room_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enumerateRoomUnits', () {
    test('excludes corridor room keys from API assignment payloads', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );

      final units = enumerateRoomUnits(breakdown);

      expect(units, hasLength(1));
      expect(units.first.roomKey, 'bedroom.small.1');
      expect(units.any((unit) => unit.roomKey.startsWith('corridor.')), isFalse);
    });
  });

  group('buildWorkerRoomAssignmentsJson', () {
    test('only assigns backend-accepted room keys', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );
      final units = enumerateRoomUnits(breakdown);

      final assignments = buildWorkerRoomAssignmentsJson(
        slotByRoomKey: {'bedroom.small.1': 1},
        units: units,
        assignmentMode: CleaningAssignmentMode.openCount,
      );

      expect(assignments, hasLength(1));
      final rooms = assignments.first['rooms'] as List;
      expect(rooms, hasLength(1));
      expect((rooms.first as Map)['roomKey'], 'bedroom.small.1');
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
