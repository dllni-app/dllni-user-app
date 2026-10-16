import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'room mode follows stable type-size-ordinal key and survives room size changes',
    () {
      var state = const CleaningProgressiveRoomState()
          .setCount(CleaningRoomType.bedroom, 2)
          .setUnitSize(CleaningRoomType.bedroom, 1, CleaningRoomSize.small)
          .setUnitCleaningType(
            CleaningRoomType.bedroom,
            1,
            CleaningType.deepCleaning,
          );
      expect(state.roomCleaningModes['bedroom.small.1'], 'deep');
      expect(state.roomCleaningModes['bedroom.medium.1'], 'regular');

      state = state.setUnitSize(
        CleaningRoomType.bedroom,
        1,
        CleaningRoomSize.large,
      );
      expect(state.roomCleaningModes['bedroom.large.1'], 'deep');
      expect(state.roomCleaningModes.containsKey('bedroom.small.1'), false);
      state = state.setCount(CleaningRoomType.bedroom, 1);
      expect(state.roomCleaningModes.length, 1);
      expect(state.roomCleaningModes['bedroom.large.1'], 'deep');
    },
  );

  test('estimate and create payload retain per-room choices', () {
    final breakdown = const CleaningRoomSizeBreakdown().setCount(
      CleaningRoomType.bedroom,
      CleaningRoomSize.small,
      1,
    );
    const roomModes = <String, String>{'bedroom.small.1': 'deep'};
    final estimate = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 0,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      roomCleaningModes: roomModes,
      cleaningType: CleaningType.regularCleaning,
      addressLatitude: null,
      addressLongitude: null,
      numberOfWorkers: 2,
    );
    final create = CreateCleaningOrderParams(
      addressId: 1,
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 0,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      roomCleaningModes: roomModes,
      cleaningType: CleaningType.regularCleaning,
      address: 'Test address',
      locationName: 'Test',
      scheduledDate: '2026-10-20',
      scheduledTime: '09:00',
      addressLatitude: null,
      addressLongitude: null,
      numberOfWorkers: 2,
    );
    expect(
      (estimate.getBody()['propertyDetails'] as Map)['room_cleaning_modes'],
      roomModes,
    );
    expect(
      (create.getBody()['propertyDetails'] as Map)['room_cleaning_modes'],
      roomModes,
    );
  });
}
