import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
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
}
