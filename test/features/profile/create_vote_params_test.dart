import 'package:dllni_user_app/features/profile/domain/usecases/create_vote_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('create vote request', () {
    test('creates a vote without the removed restaurant type', () {
      final body = CreateVoteParams(
        durationMinutes: 30,
        foodCategoryHint: 'برغر',
        options: [
          {'label': 'برغر لحم', 'productId': 1},
          {'label': 'برغر دجاج', 'productId': 2},
        ],
      ).getBody();

      expect(body.containsKey('cuisineTypeId'), isFalse);
      expect(body['durationMinutes'], 30);
      expect(body['foodCategoryHint'], 'برغر');
      expect((body['options'] as List).length, 2);
    });

    test('retains the optional cuisine type for other callers', () {
      final body = CreateVoteParams(
        durationMinutes: 45,
        options: const [],
        cuisineTypeId: 7,
      ).getBody();

      expect(body['cuisineTypeId'], 7);
    });
  });
}
