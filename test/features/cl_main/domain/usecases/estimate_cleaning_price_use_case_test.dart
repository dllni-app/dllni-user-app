import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getBody includes room_size_breakdown and legacy derived fields', () {
    const breakdown = CleaningRoomSizeBreakdown(
      bedroom: CleaningRoomSizeBucket(small: 2, medium: 1, large: 0),
      bathroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
      kitchen: CleaningRoomSizeBucket(small: 1, medium: 1, large: 0),
      livingRoom: CleaningRoomSizeBucket(small: 0, medium: 2, large: 0),
      balcony: CleaningRoomSizeBucket(small: 1, medium: 0, large: 2),
    );

    final params = EstimateCleaningPriceParams(
      propertyType: 'villa',
      bedrooms: 0,
      rooms: 0,
      bathrooms: 0,
      balconies: 99,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      addressLatitude: 33.5,
      addressLongitude: 36.3,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details['bedrooms'], breakdown.legacyBedroomsCount);
    expect(details['rooms'], breakdown.legacyRoomsCount);
    expect(details['bathrooms'], breakdown.legacyBathroomsCount);
    expect(details['balconies'], breakdown.legacyBalconiesCount);
    expect(details['living_room_size'], 'medium');
    final breakdownJson =
        details['room_size_breakdown'] as Map<String, dynamic>;
    expect(breakdownJson, breakdown.toBackendJson());
    expect(breakdownJson.keys, {
      'bedroom',
      'bathroom',
      'kitchen',
      'living_room',
      'balcony',
    });
  });

  test(
    'getBody includes corridor in room_size_breakdown when present locally',
    () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
        corridor: CleaningRoomSizeBucket(small: 0, medium: 1, large: 0),
      );

      final params = EstimateCleaningPriceParams(
        propertyType: 'villa',
        bedrooms: 0,
        rooms: 0,
        bathrooms: 0,
        livingRoomSize: 'small',
        roomSizeBreakdown: breakdown,
        addressLatitude: 33.5,
        addressLongitude: 36.3,
      );

      final details =
          params.getBody()['propertyDetails'] as Map<String, dynamic>;
      final breakdownJson =
          details['room_size_breakdown'] as Map<String, dynamic>;

      expect(breakdownJson.keys, {'bedroom', 'corridor'});
      expect(breakdownJson['corridor'], {
        'small': 0,
        'medium': 1,
        'large': 0,
      });
    },
  );

  test('getBody includes propertyDetails.cleaning_mode when provided', () {
    final params = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      cleaningType: CleaningType.deepCleaning,
      addressLatitude: 33.5,
      addressLongitude: 36.3,
    );

    expect(params.getBody()['cleaningType'], isNull);
    final details = params.getBody()['propertyDetails'] as Map<String, dynamic>;
    expect(details['cleaning_mode'], 'deep');
  });

  test('getBody omits balconies for event assistance flow', () {
    final params = EstimateCleaningPriceParams.eventAssistance(
      eventType: 'family_dinner',
      guestCount: 10,
      venueType: 'home',
      customService: 'تجهيز طاولات الضيافة',
      hours: 4,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details.containsKey('balconies'), isFalse);
  });

  test('event assistance getBody matches backend contract shape', () {
    final params = EstimateCleaningPriceParams.eventAssistance(
      eventType: 'family_dinner',
      guestCount: 20,
      venueType: 'apartment',
      customService: 'مساعدة يدوية في تجهيز الضيافة',
      hours: 6,
      numberOfWorkers: 3,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(body['propertyType'], 'event_assistance');
    expect(details['eventType'], 'family_dinner');
    expect(details['guestCount'], 20);
    expect(details['venueType'], 'apartment');
    expect(details['customService'], 'مساعدة يدوية في تجهيز الضيافة');
    expect(details['hours'], 6);
    expect(body.containsKey('serviceIds'), isFalse);
    expect(body['assignmentMode'], 'open_count');
    expect(body['numberOfWorkers'], 3);
    expect(details.containsKey('room_size_breakdown'), isFalse);
    expect(details.containsKey('cleaning_mode'), isFalse);
    expect(body.containsKey('workerRoomAssignments'), isFalse);
  });
}
