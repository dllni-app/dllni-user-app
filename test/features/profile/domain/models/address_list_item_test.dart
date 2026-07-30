import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressListItem.hasCompleteServiceLocation', () {
    AddressListItem item({
      String id = '1',
      String label = 'Home',
      String line1 = 'Aleppo - Al Furqan',
      String? neighborhood = 'الفرقان',
      double? latitude = 36.2021,
      double? longitude = 37.1343,
    }) {
      return AddressListItem(
        id: id,
        label: label,
        line1: line1,
        type: AddressType.home,
        neighborhood: neighborhood,
        latitude: latitude,
        longitude: longitude,
      );
    }

    test('requires id, label, address line, neighborhood, and coordinates', () {
      expect(item().hasCompleteServiceLocation, isTrue);
      expect(item(id: '0').hasCompleteServiceLocation, isFalse);
      expect(item(label: '').hasCompleteServiceLocation, isFalse);
      expect(item(line1: '').hasCompleteServiceLocation, isFalse);
      expect(item(neighborhood: '').hasCompleteServiceLocation, isFalse);
      expect(item(latitude: null).hasCompleteServiceLocation, isFalse);
      expect(item(longitude: null).hasCompleteServiceLocation, isFalse);
    });
  });
}
