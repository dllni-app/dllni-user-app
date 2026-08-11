import 'package:dllni_user_app/features/profile/data/models/luck_box_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuggestLuckBoxParams', () {
    test('omits optional filters when they are unavailable', () {
      final params = SuggestLuckBoxParams(
        groupSize: 2,
        budgetPerPerson: 500,
        restrictions: const [],
      );

      expect(
        params.toJson(),
        {
          'groupSize': 2,
          'budgetPerPerson': 500,
          'restrictions': <String>[],
        },
      );
    });

    test('includes location and cuisine filters when provided', () {
      final params = SuggestLuckBoxParams(
        groupSize: 4,
        budgetPerPerson: 250,
        restrictions: const ['vegetarian'],
        latitude: 33.5138,
        longitude: 36.2765,
        cuisineTypeId: 7,
      );

      expect(
        params.toJson(),
        {
          'groupSize': 4,
          'budgetPerPerson': 250,
          'restrictions': ['vegetarian'],
          'latitude': 33.5138,
          'longitude': 36.2765,
          'cuisineTypeId': 7,
        },
      );
    });
  });
}
