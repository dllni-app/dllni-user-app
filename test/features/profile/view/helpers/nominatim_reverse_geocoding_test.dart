import 'package:dllni_user_app/features/profile/view/helpers/nominatim_reverse_geocoding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NominatimReverseGeocoding.parse', () {
    test('maps common address fields into app fields', () {
      final fields = NominatimReverseGeocoding.parse(<String, dynamic>{
        'display_name': 'Mazzeh, Damascus, Syria',
        'address': <String, dynamic>{
          'city': 'Damascus',
          'suburb': 'Mazzeh',
          'road': 'Al Hamra Street',
          'house_number': '12',
        },
      });

      expect(fields.city, 'Damascus');
      expect(fields.neighborhood, 'Mazzeh');
      expect(fields.street, 'Al Hamra Street');
      expect(fields.building, '12');
      expect(fields.directions, 'Mazzeh, Damascus, Syria');
      expect(fields.hasAnyData, isTrue);
    });

    test('returns partial mapping when only some keys exist', () {
      final fields = NominatimReverseGeocoding.parse(<String, dynamic>{
        'address': <String, dynamic>{'state': 'Damascus', 'country': 'Syria'},
      });

      expect(fields.city, 'Damascus');
      expect(fields.neighborhood, isNull);
      expect(fields.street, isNull);
      expect(fields.building, isNull);
      expect(fields.directions, 'Syria');
      expect(fields.hasAnyData, isTrue);
    });
  });
}
