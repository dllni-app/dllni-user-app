import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRoomSizeBreakdown.toBackendJson', () {
    test('omits corridor and zero-count room buckets', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );

      final json = breakdown.toBackendJson();

      expect(json.keys, {'bedroom'});
      expect(json.containsKey('corridor'), isFalse);
      expect(json['bedroom'], {
        'small': 1,
        'medium': 0,
        'large': 0,
      });
    });

    test('includes only backend-accepted types with total > 0', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 2, medium: 1, large: 0),
        bathroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        kitchen: CleaningRoomSizeBucket(small: 1, medium: 1, large: 0),
        livingRoom: CleaningRoomSizeBucket(small: 0, medium: 2, large: 0),
        balcony: CleaningRoomSizeBucket(small: 1, medium: 0, large: 2),
      );

      final json = breakdown.toBackendJson();

      expect(json.keys, {
        'bedroom',
        'bathroom',
        'kitchen',
        'living_room',
        'balcony',
      });
    });
  });
}
