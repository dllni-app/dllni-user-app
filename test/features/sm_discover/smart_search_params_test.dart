import 'package:dllni_user_app/features/sm_discover/domain/usecases/smart_search_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartSearchParams API contract', () {
    test('restaurant uses canonical restaurant section', () {
      final params = SmartSearchParams(
        query: 'بدي وجبة كريسبي حارة',
        isSupermarket: false,
      );

      expect(params.getBody(), containsPair('section', 'restaurant'));
      expect(params.getBody(), containsPair('query', 'بدي وجبة كريسبي حارة'));
    });

    test('supermarket sends raw natural language without pre-normalizing it', () {
      const query = 'بدي حضر لازانيا من عند سوبرماركت الأطرش';
      final params = SmartSearchParams(
        query: query,
        isSupermarket: true,
      );

      expect(params.getBody(), containsPair('section', 'supermarket'));
      expect(params.getBody(), containsPair('query', query));
      expect(params.getBody(), containsPair('locale', 'ar'));
    });
  });
}
