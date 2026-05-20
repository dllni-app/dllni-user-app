import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/patch_cleaning_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PatchCleaningOrderParams _buildParams({
    CleaningGenderPreference genderPreference = CleaningGenderPreference.any,
  }) {
    return PatchCleaningOrderParams(
      cleaningOrderId: 42,
      propertyType: 'apartment',
      scheduledDate: '2026-05-30',
      scheduledTime: '10:00',
      address: 'Address',
      bedrooms: 2,
      rooms: 3,
      bathrooms: 1,
      livingRoomSize: 'medium',
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
      genderPreference: CleaningGenderPreference.male,
    );
    final body = params.getBody();

    expect(body['genderPreference'], 'male');
  });
}
