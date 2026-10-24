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
    expect(CleaningRoomType.fromCode('utility-9').apiKey, 'utility-9');
  });

  test(
    'room code grammar accepts max-width ASCII and rejects invalid codes',
    () {
      final maxCode = 'a${'b' * 61}-9';
      expect(maxCode, hasLength(64));
      expect(CleaningRoomType.fromCode(maxCode).apiKey, maxCode);

      for (final invalid in [
        '${maxCode}x',
        'Uppercase',
        'room_é',
        'room.name',
        '9room',
        'room\n',
      ]) {
        expect(() => CleaningRoomType.fromCode(invalid), throwsArgumentError);
      }
    },
  );

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

  test(
    'max-width hyphenated code survives breakdown and V2 draft keys intact',
    () {
      final code = 'a${'b' * 61}-9';
      final roomType = CleaningRoomType.fromCode(code);
      final progressiveState = const CleaningProgressiveRoomState().setCount(
        roomType,
        1,
      );
      expect(progressiveState.roomCleaningModes, {
        '$code.medium.1': CleaningType.regularCleaning.cleaningModeValue,
      });
      final breakdown = const CleaningRoomSizeBreakdown().setCount(
        roomType,
        CleaningRoomSize.medium,
        1,
      );
      expect(breakdown.toBackendJson().keys, [code]);

      var draft = CleaningBookingDraft.fromRooms([
        CleaningProgressiveRoomUnit(
          roomType: roomType,
          index: 999,
          size: CleaningRoomSize.medium,
        ),
      ], DateTime(2026, 10, 24));
      final payload = draft.toJson();
      final room = (payload['rooms'] as List).single as Map;
      final visit = (payload['visits'] as List).single as Map;
      final schedule = (visit['roomSchedules'] as List).single as Map;

      expect(room['roomKey'], '$code.999');
      expect(room['roomType'], code);
      expect(schedule['roomKey'], '$code.999');
      expect(schedule['scheduleKey'], 'visit.1.$code.999');
      expect((room['roomKey'] as String).length, 68);
      expect((schedule['scheduleKey'] as String).length, 76);

      for (var visitSequence = 2; visitSequence <= 30; visitSequence++) {
        draft = draft.addVisit(DateTime(2026, 10, 24 + visitSequence));
      }
      expect(draft.schedules.last.scheduleKey, 'visit.30.$code.999');
      expect(draft.schedules.last.scheduleKey.length, 77);
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
