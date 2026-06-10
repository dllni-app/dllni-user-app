import 'package:dllni_user_app/features/cl_main/domain/models/cl_worker_room_assignment_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningWorkerRoomAssignment', () {
    test('fromJson parses normalized estimate slot fields', () {
      final assignment = CleaningWorkerRoomAssignment.fromJson({
        'workerSlot': 1,
        'preferredWorkerId': null,
        'roomsWeight': 2.5,
        'estimatedServiceShareAmount': 5500,
        'rooms': [
          {
            'roomKey': 'bedroom.small.1',
            'roomType': 'bedroom',
            'roomSize': 'small',
          },
        ],
      });

      expect(assignment.workerSlot, 1);
      expect(assignment.preferredWorkerId, isNull);
      expect(assignment.roomsWeight, 2.5);
      expect(assignment.estimatedServiceShareAmount, 5500);
      expect(assignment.rooms, hasLength(1));
      expect(assignment.rooms.first.roomKey, 'bedroom.small.1');
    });

    test('toRequestJson emits create payload shape', () {
      final assignment = CleaningWorkerRoomAssignment(
        workerSlot: 2,
        rooms: const [
          CleaningWorkerRoomAssignmentRoom(
            roomKey: 'kitchen.medium.1',
            roomType: 'kitchen',
            roomSize: 'medium',
          ),
        ],
      );

      expect(
        assignment.toRequestJson(),
        {
          'workerSlot': 2,
          'preferredWorkerId': null,
          'rooms': [
            {
              'roomKey': 'kitchen.medium.1',
              'roomType': 'kitchen',
              'roomSize': 'medium',
            },
          ],
        },
      );
    });
  });

  group('workerRoomAssignmentsToRequestJson', () {
    test('drops slots with empty rooms arrays', () {
      final payload = workerRoomAssignmentsToRequestJson([
        CleaningWorkerRoomAssignment(
          workerSlot: 1,
          rooms: const [
            CleaningWorkerRoomAssignmentRoom(
              roomKey: 'living_room.large.1',
              roomType: 'living_room',
              roomSize: 'large',
            ),
          ],
        ),
        const CleaningWorkerRoomAssignment(workerSlot: 2),
        const CleaningWorkerRoomAssignment(workerSlot: 3),
        CleaningWorkerRoomAssignment(
          workerSlot: 4,
          rooms: const [
            CleaningWorkerRoomAssignmentRoom(
              roomKey: 'bedroom.small.1',
              roomType: 'bedroom',
              roomSize: 'small',
            ),
          ],
        ),
      ]);

      expect(payload, hasLength(2));
      expect(payload.map((entry) => entry['workerSlot']), [1, 4]);
      expect(
        payload.every((entry) => (entry['rooms'] as List).isNotEmpty),
        isTrue,
      );
    });
  });
}
