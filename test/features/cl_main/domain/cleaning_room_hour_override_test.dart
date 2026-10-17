import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_booking_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';

void main() {
  test('manual room hours travel with the V2 booking payload', () {
    final rooms = const CleaningProgressiveRoomState()
        .setCount(CleaningRoomType.kitchen, 1)
        .setUnitEstimatedHours(CleaningRoomType.kitchen, 1, 1.75);
    final draft = CleaningBookingDraft.fromRooms(
      rooms.units,
      DateTime(2026, 10, 21),
    );
    final entries = draft.toJson()['rooms'] as List;
    expect(entries.single['roomType'], 'kitchen');
    expect(entries.single['estimatedHours'], 1.75);
  });

  test('changing cleaning mode clears the previous hour override', () {
    final original = const CleaningProgressiveRoomState()
        .setCount(CleaningRoomType.bedroom, 1)
        .setUnitEstimatedHours(CleaningRoomType.bedroom, 1, 3);
    final revised = original.setUnitCleaningType(
      CleaningRoomType.bedroom,
      1,
      CleaningType.deepCleaning,
    );
    expect(revised.units.single.estimatedHours, isNull);
  });
}
