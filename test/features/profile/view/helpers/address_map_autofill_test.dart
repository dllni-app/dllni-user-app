import 'package:dllni_user_app/features/profile/view/helpers/address_map_autofill.dart';
import 'package:dllni_user_app/features/profile/view/helpers/nominatim_reverse_geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressMapAutofill.applyCoreFields', () {
    test('updates only city, neighborhood, and street', () {
      final city = TextEditingController(text: 'Old City');
      final neighborhood = TextEditingController();
      final street = TextEditingController(text: 'Old Street');
      final building = TextEditingController(text: 'Tower A');
      final floor = TextEditingController(text: '3');

      AddressMapAutofill.applyCoreFields(
        fields: const NominatimAddressFields(
          city: 'Damascus',
          neighborhood: 'Mazzeh',
          street: 'Al Hamra Street',
          building: '12',
          directions: 'Mazzeh, Damascus, Syria',
        ),
        cityController: city,
        neighborhoodController: neighborhood,
        streetController: street,
        buildingController: building,
        floorController: floor,
        cityEdited: false,
        neighborhoodEdited: false,
        streetEdited: false,
        forceFill: false,
      );

      expect(city.text, 'Damascus');
      expect(neighborhood.text, 'Mazzeh');
      expect(street.text, 'Al Hamra Street');
      expect(building.text, 'Tower A');
      expect(floor.text, '3');
    });

    test('does not overwrite manually edited fields unless forceFill is true', () {
      final city = TextEditingController(text: 'Manual City');
      final neighborhood = TextEditingController();
      final street = TextEditingController();

      AddressMapAutofill.applyCoreFields(
        fields: const NominatimAddressFields(
          city: 'Damascus',
          neighborhood: 'Mazzeh',
          street: 'Al Hamra Street',
        ),
        cityController: city,
        neighborhoodController: neighborhood,
        streetController: street,
        buildingController: TextEditingController(),
        floorController: TextEditingController(),
        cityEdited: true,
        neighborhoodEdited: false,
        streetEdited: false,
        forceFill: false,
      );

      expect(city.text, 'Manual City');
      expect(neighborhood.text, 'Mazzeh');
      expect(street.text, 'Al Hamra Street');
    });
  });
}
