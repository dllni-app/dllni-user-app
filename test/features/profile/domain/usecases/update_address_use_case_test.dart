import 'package:dllni_user_app/features/profile/domain/usecases/update_address_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateAddressParams body', () {
    test('includes latitude and longitude when provided', () {
      final params = UpdateAddressParams(
        addressId: 1,
        label: 'Home',
        mobile: '09999',
        city: 'Damascus',
        neighborhood: 'Mazzeh',
        street: 'Street 1',
        building: 'B1',
        floor: '2',
        directions: 'near park',
        isDefault: true,
        latitude: 33.51,
        longitude: 36.27,
      );

      final body = params.getBody();
      expect(body['latitude'], 33.51);
      expect(body['longitude'], 36.27);
    });

    test('omits latitude and longitude when null', () {
      final params = UpdateAddressParams(
        addressId: 1,
        label: 'Home',
        mobile: '09999',
        city: 'Damascus',
        neighborhood: 'Mazzeh',
        street: 'Street 1',
        building: 'B1',
        floor: '2',
        directions: 'near park',
        isDefault: true,
      );

      final body = params.getBody();
      expect(body.containsKey('latitude'), isFalse);
      expect(body.containsKey('longitude'), isFalse);
    });
  });
}
