import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningProgressiveRoomState', () {
    test('preserves room choices when counts grow and shrink', () {
      var state = const CleaningProgressiveRoomState()
          .setCount(CleaningRoomType.bedroom, 2)
          .setUnitSize(CleaningRoomType.bedroom, 1, CleaningRoomSize.small)
          .setUnitSize(CleaningRoomType.bedroom, 2, CleaningRoomSize.large);

      state = state.setCount(CleaningRoomType.bedroom, 3);

      expect(state.units, hasLength(3));
      expect(state.units[0].size, CleaningRoomSize.small);
      expect(state.units[1].size, CleaningRoomSize.large);
      expect(state.units[2].size, CleaningRoomSize.medium);

      state = state.setCount(CleaningRoomType.bedroom, 1);

      expect(state.units, hasLength(1));
      expect(state.units.single.size, CleaningRoomSize.small);
    });

    test('converts individual room units to backend breakdown', () {
      final state = const CleaningProgressiveRoomState()
          .setCount(CleaningRoomType.bedroom, 2)
          .setCount(CleaningRoomType.bathroom, 1)
          .setCount(CleaningRoomType.kitchen, 1)
          .setUnitSize(CleaningRoomType.bedroom, 1, CleaningRoomSize.small)
          .setUnitSize(CleaningRoomType.bedroom, 2, CleaningRoomSize.large)
          .setUnitSize(CleaningRoomType.bathroom, 1, CleaningRoomSize.medium);

      final breakdown = state.toBreakdown();

      expect(breakdown.toBackendJson(), {
        'bedroom': {'small': 1, 'medium': 0, 'large': 1},
        'bathroom': {'small': 0, 'medium': 1, 'large': 0},
        'kitchen': {'small': 0, 'medium': 1, 'large': 0},
      });
      expect(breakdown.legacyBedroomsCount, 2);
      expect(breakdown.legacyBathroomsCount, 1);
      expect(breakdown.legacyRoomsCount, 4);
    });

    test('keeps counters inside server limits and still allows balconies', () {
      var state = const CleaningProgressiveRoomState()
          .setCount(CleaningRoomType.bedroom, 999)
          .setCount(CleaningRoomType.bathroom, 999)
          .setCount(CleaningRoomType.kitchen, 100)
          .setCount(CleaningRoomType.balcony, 999);

      expect(state.countFor(CleaningRoomType.bedroom), 20);
      expect(state.countFor(CleaningRoomType.bathroom), 10);
      expect(state.countFor(CleaningRoomType.kitchen), 0);
      expect(state.countFor(CleaningRoomType.balcony), 20);
      expect(state.totalBaseRooms, 30);
      expect(state.toBreakdown().legacyRoomsCount, 30);
      expect(state.maxCountFor(CleaningRoomType.kitchen), 0);

      state = state.setCount(CleaningRoomType.bedroom, 5);
      expect(state.maxCountFor(CleaningRoomType.kitchen), 15);
      state = state.setCount(CleaningRoomType.kitchen, 99);
      expect(state.countFor(CleaningRoomType.kitchen), 15);
      expect(state.totalBaseRooms, 30);
    });

    test('balcony alone cannot start a cleaning quote', () {
      final state = const CleaningProgressiveRoomState().setCount(
        CleaningRoomType.balcony,
        1,
      );
      expect(state.hasAnyRoom, isFalse);
      expect(state.toBreakdown().hasAnyRoom, isFalse);
      expect(state.setCount(CleaningRoomType.livingRoom, 1).hasAnyRoom, isTrue);
    });

    test('round trips an existing backend breakdown', () {
      const original = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, large: 2),
        bathroom: CleaningRoomSizeBucket(medium: 1),
        livingRoom: CleaningRoomSizeBucket(large: 1),
        balcony: CleaningRoomSizeBucket(small: 1),
      );

      final state = CleaningProgressiveRoomState.fromBreakdown(original);
      final result = state.toBreakdown();

      expect(result.toBackendJson(), original.toBackendJson());
      expect(state.countFor(CleaningRoomType.bedroom), 3);
      expect(state.countFor(CleaningRoomType.balcony), 1);
    });
  });
}
