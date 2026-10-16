import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_period_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime(2026, 10, 20);
  final rooms = const CleaningProgressiveRoomState()
      .setCount(CleaningRoomType.bedroom, 2)
      .setUnitCleaningType(
        CleaningRoomType.bedroom,
        1,
        CleaningType.deepCleaning,
      )
      .setUnitSize(CleaningRoomType.bedroom, 1, CleaningRoomSize.large);

  test('every room is independently serialized with its stable identifier', () {
    final state = CleaningRoomPeriodDrafts.fromRooms(rooms.units, date: date);
    final first = state.periods.first.copyWith(
      workers: 2,
      scheduledTime: '09:30',
      providedByPlatform: true,
    );
    final updated = state.replace(first);
    expect(updated.toApiJson(), hasLength(2));
    expect(updated.toApiJson()[0]['clientKey'], 'bedroom.1');
    expect(updated.toApiJson()[0]['size'], 'large');
    expect(updated.toApiJson()[0]['cleaningMode'], 'deep');
    expect(updated.toApiJson()[0]['numberOfWorkers'], 2);
    expect(updated.toApiJson()[1]['numberOfWorkers'], 1);
    expect(updated.toApiJson()[1]['cleaningMode'], 'regular');
    expect(updated.toApiJson()[0]['materials']['providedByPlatform'], isTrue);
    expect(updated.toApiJson()[1]['materials']['providedByPlatform'], isFalse);
  });

  test(
    'copy all requirements clones values but later edits are independent',
    () {
      var state = CleaningRoomPeriodDrafts.fromRooms(rooms.units, date: date);
      state = state.replace(
        state.periods.first.copyWith(
          materialTypeIds: const [7, 12],
          specialServices: const [
            {'specialServiceId': 9, 'quantity': 2, 'dirtinessLevel': 'light'},
          ],
        ),
      );
      state = state.copyRequirementsToAll('bedroom.1');
      expect(state.periods.last.materialTypeIds, [7, 12]);
      expect(state.periods.last.specialServices, hasLength(1));
      state = state.replace(
        state.periods.last.copyWith(materialTypeIds: const [7]),
      );
      expect(state.periods.first.materialTypeIds, [7, 12]);
      expect(state.periods.last.materialTypeIds, [7]);
    },
  );

  test(
    'changing the size of a room preserves its period identity and settings',
    () {
      final initial = CleaningRoomPeriodDrafts.fromRooms(
        rooms.units,
        date: date,
      );
      final customized = initial.replace(
        initial.periods.first.copyWith(workers: 3),
      );
      final resized = rooms.setUnitSize(
        CleaningRoomType.bedroom,
        1,
        CleaningRoomSize.small,
      );
      final next = customized.reconcileRooms(resized.units, defaultDate: date);
      expect(next.periods.first.clientKey, 'bedroom.1');
      expect(next.periods.first.workers, 3);
      expect(next.periods.first.room.size, CleaningRoomSize.small);
    },
  );

  test('copying materials never overwrites specialized services', () {
    var drafts = CleaningRoomPeriodDrafts.fromRooms(rooms.units, date: date);
    drafts = drafts.replace(
      drafts.periods.first.copyWith(
        materialTypeIds: const [7, 12],
        specialServices: const [
          {'specialServiceId': 5, 'quantity': 1},
        ],
      ),
    );
    drafts = drafts.replace(
      drafts.periods.last.copyWith(
        specialServices: const [
          {'specialServiceId': 9, 'quantity': 3},
        ],
      ),
    );
    final copied = drafts.copyMaterialsToAll('bedroom.1');
    expect(copied.periods.last.materialTypeIds, [7, 12]);
    expect(copied.periods.last.specialServices.single['specialServiceId'], 9);
  });

  test('copying services never overwrites materials or worker counts', () {
    var drafts = CleaningRoomPeriodDrafts.fromRooms(rooms.units, date: date);
    drafts = drafts.replace(
      drafts.periods.first.copyWith(
        specialServices: const [
          {'specialServiceId': 5, 'quantity': 2},
        ],
      ),
    );
    drafts = drafts.replace(
      drafts.periods.last.copyWith(workers: 3, materialTypeIds: const [10]),
    );
    final copied = drafts.copySpecialServicesToAll('bedroom.1');
    expect(copied.periods.last.specialServices.single['quantity'], 2);
    expect(copied.periods.last.materialTypeIds, [10]);
    expect(copied.periods.last.workers, 3);
  });
}
