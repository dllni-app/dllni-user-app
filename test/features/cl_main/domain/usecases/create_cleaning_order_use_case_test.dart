import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
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
    final breakdownJson =
        details['room_size_breakdown'] as Map<String, dynamic>;
    expect(breakdownJson, breakdown.toBackendJson());
  });

  test('getBody includes propertyDetails.cleaning_mode when provided', () {
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

    expect(params.getBody()['cleaningType'], isNull);
    final details = params.getBody()['propertyDetails'] as Map<String, dynamic>;
    expect(details['cleaning_mode'], 'regular');
  });

  test('getBody sends cleaning_services as sanitized strings', () {
    final params = CreateCleaningOrderParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      address: 'Address',
      locationName: 'Home',
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      addressLatitude: 33.5,
      addressLongitude: 36.3,
      cleaningServices: const [
        ' تنظيف النوافذ ',
        '',
        'تنظيف المطبخ',
        'تنظيف النوافذ',
      ],
    );

    final body = params.getBody();

    expect(body['cleaning_services'], ['تنظيف النوافذ', 'تنظيف المطبخ']);
    expect(body.containsKey('serviceIds'), isFalse);
  });

  test('getBody omits balconies for event assistance flow', () {
    final params = CreateCleaningOrderParams.eventAssistance(
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      eventType: 'family_dinner',
      guestCount: 12,
      venueType: 'home',
      customService: 'دعم إضافي لمنطقة الضيافة',
      hours: 3,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details.containsKey('balconies'), isFalse);
  });

  test('event assistance create uses preferred worker assignment mode', () {
    final params = CreateCleaningOrderParams.eventAssistance(
      scheduledDate: '2026-06-11',
      scheduledTime: '09:00',
      eventType: 'family_dinner',
      guestCount: 20,
      venueType: 'apartment',
      customService: 'تجهيز طاولات الضيافة',
      hours: 5,
      address: 'دمشق',
      locationName: 'المنزل',
      addressLatitude: 33.51,
      addressLongitude: 36.27,
      assignmentMode: CleaningAssignmentMode.preferredWorker,
      preferredWorkerId: 77,
      numberOfWorkers: 1,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(details['customService'], 'تجهيز طاولات الضيافة');
    expect(details['hours'], 5);
    expect(body['assignmentMode'], 'preferred_worker');
    expect(body['preferredWorkerId'], 77);
    expect(body['numberOfWorkers'], 1);
    expect(body.containsKey('serviceIds'), isFalse);
    expect(body.containsKey('cleaning_services'), isFalse);
    expect(body.containsKey('workerRoomAssignments'), isFalse);
  });

  test('event assistance create matches backend contract shape', () {
    final params = CreateCleaningOrderParams.eventAssistance(
      scheduledDate: '2026-06-11',
      scheduledTime: '09:00',
      eventType: 'family_dinner',
      guestCount: 20,
      venueType: 'apartment',
      customService: 'مساعدة يدوية في تجهيز الضيافة',
      hours: 4,
      address: 'دمشق',
      locationName: 'المنزل',
      addressLatitude: 33.51,
      addressLongitude: 36.27,
      numberOfWorkers: 2,
    );

    final body = params.getBody();
    final details = body['propertyDetails'] as Map<String, dynamic>;

    expect(body['propertyType'], 'event_assistance');
    expect(details['customService'], 'مساعدة يدوية في تجهيز الضيافة');
    expect(details['hours'], 4);
    expect(body['assignmentMode'], 'open_count');
    expect(body['numberOfWorkers'], 2);
    expect(body.containsKey('serviceIds'), isFalse);
    expect(body.containsKey('cleaning_services'), isFalse);
    expect(details.containsKey('room_size_breakdown'), isFalse);
    expect(details.containsKey('cleaning_mode'), isFalse);
    expect(body.containsKey('workerRoomAssignments'), isFalse);
  });

  test('estimate and create share pricing fields for home cleaning', () {
    const breakdown = CleaningRoomSizeBreakdown(
      bedroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
      bathroom: CleaningRoomSizeBucket(small: 1, medium: 0, large: 0),
    );

    final estimateParams = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      cleaningType: CleaningType.deepCleaning,
      addressLatitude: 33.5,
      addressLongitude: 36.3,
      numberOfWorkers: 2,
      assignmentMode: CleaningAssignmentMode.openCount,
    );

    final createParams = CreateCleaningOrderParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      roomSizeBreakdown: breakdown,
      cleaningType: CleaningType.deepCleaning,
      address: 'Address',
      locationName: 'Home',
      scheduledDate: '2026-06-11',
      scheduledTime: '09:00',
      addressLatitude: 33.5,
      addressLongitude: 36.3,
      numberOfWorkers: 2,
      assignmentMode: CleaningAssignmentMode.openCount,
    );

    final estimateBody = estimateParams.getBody();
    final createBody = createParams.getBody();

    expect(createBody['propertyType'], estimateBody['propertyType']);

    final estimateDetails =
        estimateBody['propertyDetails'] as Map<String, dynamic>;
    final createDetails = createBody['propertyDetails'] as Map<String, dynamic>;
    for (final key in [
      'bedrooms',
      'rooms',
      'bathrooms',
      'balconies',
      'living_room_size',
      'room_size_breakdown',
      'cleaning_mode',
    ]) {
      expect(createDetails[key], estimateDetails[key], reason: key);
    }

    expect(createBody['addressLatitude'], estimateBody['addressLatitude']);
    expect(createBody['addressLongitude'], estimateBody['addressLongitude']);
    expect(createBody['assignmentMode'], estimateBody['assignmentMode']);
    expect(createBody['numberOfWorkers'], estimateBody['numberOfWorkers']);
    expect(createBody['cleaningType'], isNull);
    expect(estimateBody['cleaningType'], isNull);
    expect(estimateBody.containsKey('serviceIds'), isFalse);
  });
}
