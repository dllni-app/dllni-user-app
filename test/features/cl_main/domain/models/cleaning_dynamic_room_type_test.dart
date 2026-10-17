import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_booking_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cl_worker_room_assignment.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('server room codes have stable identity, including legacy aliases', () {
    expect(CleaningRoomType.fromCode('bedroom'), CleaningRoomType.bedroom);
    expect(
      CleaningRoomType.fromCode('study_room'),
      CleaningRoomType.fromCode('study_room'),
    );
    expect(
      CleaningRoomType.fromCode('study_room').hashCode,
      CleaningRoomType.fromCode('study_room').hashCode,
    );
    expect(
      () => CleaningRoomType.fromCode('invalid-hyphen'),
      throwsArgumentError,
    );
  });

  test(
    'custom room survives counts, size, mode, hours and V2 serialization',
    () {
      final study = CleaningRoomType.fromCode('study_room');
      var state = const CleaningProgressiveRoomState()
          .setCount(study, 2)
          .setCount(CleaningRoomType.bedroom, 1)
          .setUnitSize(study, 1, CleaningRoomSize.large)
          .setUnitCleaningType(study, 1, CleaningType.deepCleaning)
          .setUnitEstimatedHours(study, 1, 2.25)
          .withRoomNames({'study_room': 'غرفة المكتب'});

      expect(state.countFor(study), 2);
      expect(state.totalBaseRooms, 3);
      expect(state.roomCleaningModes['study_room.large.1'], 'deep');
      expect(
        state.units
            .firstWhere((unit) => unit.key == 'study_room.1')
            .estimatedHours,
        2.25,
      );
      expect(state.toBreakdown().toBackendJson()['study_room'], {
        'small': 0,
        'medium': 1,
        'large': 1,
      });

      final draft = CleaningBookingDraft.fromRooms(
        state.units,
        DateTime(2026, 10, 24),
      );
      final rooms = (draft.toJson()['rooms'] as List).cast<Map>();
      expect(rooms.firstWhere((room) => room['roomKey'] == 'study_room.1'), {
        'roomKey': 'study_room.1',
        'roomType': 'study_room',
        'size': 'large',
        'cleaningMode': 'deep',
        'estimatedHours': 2.25,
      });
      expect(
        cleaningRoomLabel(
          state.units.firstWhere((unit) => unit.key == 'study_room.1'),
        ),
        'غرفة المكتب 1',
      );

      state = state.setCount(study, 1);
      expect(
        state.units
            .firstWhere((unit) => unit.key == 'study_room.1')
            .estimatedHours,
        2.25,
      );
      expect(state.units.where((unit) => unit.roomType == study), hasLength(1));
    },
  );

  test(
    'custom rooms round-trip the legacy breakdown without losing counts',
    () {
      final custom = CleaningRoomType.fromCode('utility_room');
      final breakdown = const CleaningRoomSizeBreakdown()
          .setCount(custom, CleaningRoomSize.small, 2)
          .setCount(CleaningRoomType.kitchen, CleaningRoomSize.large, 1);
      expect(breakdown.legacyRoomsCount, 3);
      expect(breakdown.hasAnyRoom, true);
      final restored = CleaningProgressiveRoomState.fromBreakdown(breakdown);
      expect(restored.countFor(custom), 2);
      expect(restored.toBreakdown().toBackendJson(), breakdown.toBackendJson());
      final assignments = enumerateRoomUnits(breakdown);
      expect(
        assignments.where((unit) => unit.roomType == 'utility_room'),
        hasLength(2),
      );
      expect(
        assignments
            .firstWhere((unit) => unit.roomType == 'utility_room')
            .roomKey,
        'utility_room.small.1',
      );
    },
  );

  test('new dynamic rooms obey the same aggregate room cap', () {
    final custom = CleaningRoomType.fromCode('studio_annex');
    final state = const CleaningProgressiveRoomState()
        .setCount(CleaningRoomType.bedroom, 20)
        .setCount(custom, 20);
    expect(state.countFor(custom), 10);
    expect(state.totalBaseRooms, 30);
    expect(state.maxCountFor(custom), 10);
  });
}
