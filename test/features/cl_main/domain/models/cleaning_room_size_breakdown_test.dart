import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRoomSizeBreakdown legacy mapping', () {
    test(
      'derives legacy counters from room bucket totals while excluding balconies',
      () {
        const breakdown = CleaningRoomSizeBreakdown(
          bedroom: CleaningRoomSizeBucket(small: 1, medium: 2, large: 0),
          bathroom: CleaningRoomSizeBucket(small: 2, medium: 0, large: 1),
          kitchen: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
          livingRoom: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
          balcony: CleaningRoomSizeBucket(small: 1, medium: 1, large: 1),
        );

        expect(breakdown.totalRooms, 8);
        expect(breakdown.legacyBedroomsCount, 8);
        expect(breakdown.legacyRoomsCount, 3);
        expect(breakdown.legacyBathroomsCount, 3);
        expect(breakdown.legacyBalconiesCount, 3);
      },
    );

    test('includes corridor in totalRooms and serialization map', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );

      expect(breakdown.totalRooms, 2);
      expect(breakdown.toJson(), {
        'bedroom': {'small': 1, 'medium': 0, 'large': 0},
        'bathroom': {'small': 0, 'medium': 0, 'large': 0},
        'kitchen': {'small': 0, 'medium': 0, 'large': 0},
        'living_room': {'small': 0, 'medium': 0, 'large': 0},
        'balcony': {'small': 0, 'medium': 0, 'large': 0},
        'corridor': {'small': 0, 'medium': 1, 'large': 0},
      });
    });

    test('serializes balcony buckets inside room_size_breakdown', () {
      const breakdown = CleaningRoomSizeBreakdown(
        balcony: CleaningRoomSizeBucket(small: 2, medium: 1, large: 0),
      );

      expect(breakdown.toJson(), {
        'bedroom': {'small': 0, 'medium': 0, 'large': 0},
        'bathroom': {'small': 0, 'medium': 0, 'large': 0},
        'kitchen': {'small': 0, 'medium': 0, 'large': 0},
        'living_room': {'small': 0, 'medium': 0, 'large': 0},
        'balcony': {'small': 2, 'medium': 1, 'large': 0},
        'corridor': {'small': 0, 'medium': 0, 'large': 0},
      });
    });

    test('balcony-only input does not satisfy hasAnyRoom', () {
      const breakdown = CleaningRoomSizeBreakdown(
        balcony: CleaningRoomSizeBucket(small: 2, medium: 0, large: 1),
      );

      expect(breakdown.totalRooms, 0);
      expect(breakdown.hasAnyRoom, isFalse);
    });

    test('living room fallback prefers large over medium over small', () {
      const withLarge = CleaningRoomSizeBreakdown(
        livingRoom: CleaningRoomSizeBucket(small: 3, medium: 2, large: 1),
      );
      const withMedium = CleaningRoomSizeBreakdown(
        livingRoom: CleaningRoomSizeBucket(small: 3, medium: 2, large: 0),
      );
      const withSmallOnly = CleaningRoomSizeBreakdown(
        livingRoom: CleaningRoomSizeBucket(small: 2, medium: 0, large: 0),
      );
      const withoutLivingRoom = CleaningRoomSizeBreakdown();

      expect(withLarge.legacyLivingRoomSize, 'large');
      expect(withMedium.legacyLivingRoomSize, 'medium');
      expect(withSmallOnly.legacyLivingRoomSize, 'small');
      expect(withoutLivingRoom.legacyLivingRoomSize, 'small');
    });
  });
}
