import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CreateCleaningOrderParams _buildParams({
    CleaningGenderPreference genderPreference = CleaningGenderPreference.any,
  }) {
    return CreateCleaningOrderParams(
      propertyType: 'apartment',
      bedrooms: 2,
      rooms: 3,
      bathrooms: 1,
      balconies: 2,
      livingRoomSize: 'medium',
      address: 'Address',
      locationName: 'Home',
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      addressLatitude: 33.5,
      addressLongitude: 36.3,
      genderPreference: genderPreference,
    );
  }

  test('getBody includes genderPreference and defaults to any', () {
    final params = _buildParams();
    final body = params.getBody();

    expect(params.genderPreference, CleaningGenderPreference.any);
    expect(body['genderPreference'], 'any');
  });

  test('getBody includes selected genderPreference value', () {
    final params = _buildParams(
      genderPreference: CleaningGenderPreference.female,
    );
    final body = params.getBody();

    expect(body['genderPreference'], 'female');
  });

  test('getBody includes room_size_breakdown and legacy derived fields', () {
    const breakdown = CleaningRoomSizeBreakdown(
      bedroom: CleaningRoomSizeBucket(small: 1, medium: 2, large: 1),
      bathroom: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      kitchen: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
      livingRoom: CleaningRoomSizeBucket(small: 0, medium: 1, large: 1),
      balcony: CleaningRoomSizeBucket(small: 2, medium: 1, large: 0),
    );
    final params = CreateCleaningOrderParams(
      propertyType: 'apartment',
      bedrooms: 0,
      rooms: 0,
      bathrooms: 0,
      balconies: 77,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      address: 'Address',
      locationName: 'Home',
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      addressLatitude: 33.5,
      addressLongitude: 36.3,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details['bedrooms'], breakdown.legacyBedroomsCount);
    expect(details['rooms'], breakdown.legacyRoomsCount);
    expect(details['bathrooms'], breakdown.legacyBathroomsCount);
    expect(details['balconies'], breakdown.legacyBalconiesCount);
    expect(details['living_room_size'], 'large');
    final breakdownJson = details['room_size_breakdown'] as Map<String, dynamic>;
    expect(breakdownJson, breakdown.toJson());
    expect(breakdownJson.keys, {
      'bedroom',
      'bathroom',
      'kitchen',
      'living_room',
      'balcony',
      'corridor',
    });
    expect(breakdownJson.containsKey('corridor'), isTrue);
  });

  test('getBody includes top-level cleaningType when provided', () {
    final params = CreateCleaningOrderParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      cleaningType: CleaningType.regularCleaning,
      address: 'Address',
      locationName: 'Home',
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      addressLatitude: 33.5,
      addressLongitude: 36.3,
    );

    expect(params.getBody()['cleaningType'], 'regular_cleaning');
  });

  test('getBody omits balconies for event assistance flow', () {
    final params = CreateCleaningOrderParams.eventAssistance(
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      eventType: 'family_dinner',
      guestCount: 12,
      venueType: 'home',
      serviceIds: const [1],
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details.containsKey('balconies'), isFalse);
  });
}
