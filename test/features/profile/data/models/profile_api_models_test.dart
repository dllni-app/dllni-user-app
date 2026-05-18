import 'package:dllni_user_app/features/profile/data/models/profile_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FetchAddressesModel parsing', () {
    test('parses latitude and longitude from address resources', () {
      final model = fetchAddressesModelFromJson(<String, dynamic>{
        'addresses': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 10,
            'label': 'Home',
            'city': 'Damascus',
            'neighborhood': 'Mazzeh',
            'street': 'Street 1',
            'latitude': '33.5138',
            'longitude': 36.2765,
            'isDefault': true,
          },
        ],
      });

      final address = model.addresses!.first;
      expect(address.id, 10);
      expect(address.latitude, 33.5138);
      expect(address.longitude, 36.2765);
      expect(address.isDefault, isTrue);
    });
  });
}
