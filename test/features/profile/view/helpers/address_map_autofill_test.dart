import 'package:dllni_user_app/features/profile/view/helpers/address_map_autofill.dart';
import 'package:dllni_user_app/features/profile/view/helpers/nominatim_reverse_geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressMapAutofill.applyCoreFields', () {
    test('updates only city, neighborhood, and street', () {
      final cityController = TextEditingController(text: 'Old City');
      final neighborhoodController = TextEditingController(text: 'Old Area');
      final streetController = TextEditingController(text: 'Old Street');
      final buildingController = TextEditingController(text: 'Building 9');
      final floorController = TextEditingController(text: '3');

      AddressMapAutofill.applyCoreFields(
        fields: const NominatimAddressFields(
          city: 'Damascus',
          neighborhood: 'Mazzeh',
          street: 'Main Street',
          building: 'Auto Building',
          directions: 'Near park',
        ),
        cityController: cityController,
        neighborhoodController: neighborhoodController,
        streetController: streetController,
        buildingController: buildingController,
        floorController: floorController,
        cityEdited: false,
        neighborhoodEdited: false,
        streetEdited: false,
        forceFill: true,
      );

      expect(cityController.text, 'Damascus');
      expect(neighborhoodController.text, 'Mazzeh');
      expect(streetController.text, 'Main Street');
      expect(buildingController.text, 'Building 9');
      expect(floorController.text, '3');
    });

    test('does not overwrite manually edited core fields unless forced', () {
      final cityController = TextEditingController(text: 'Manual City');
      final neighborhoodController = TextEditingController(text: 'Manual Area');
      final streetController = TextEditingController(text: 'Manual Street');
      final buildingController = TextEditingController();
      final floorController = TextEditingController();

      AddressMapAutofill.applyCoreFields(
        fields: const NominatimAddressFields(
          city: 'Damascus',
          neighborhood: 'Mazzeh',
          street: 'Main Street',
        ),
        cityController: cityController,
        neighborhoodController: neighborhoodController,
        streetController: streetController,
        buildingController: buildingController,
        floorController: floorController,
        cityEdited: true,
        neighborhoodEdited: true,
        streetEdited: true,
        forceFill: false,
      );

      expect(cityController.text, 'Manual City');
      expect(neighborhoodController.text, 'Manual Area');
      expect(streetController.text, 'Manual Street');
    });
  });
}
