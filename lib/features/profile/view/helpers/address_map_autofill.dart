import 'package:flutter/material.dart';

import 'nominatim_reverse_geocoding.dart';

class AddressMapAutofill {
  AddressMapAutofill._();

  static void applyCoreFields({
    required NominatimAddressFields fields,
    required TextEditingController cityController,
    required TextEditingController neighborhoodController,
    required TextEditingController streetController,
    required TextEditingController buildingController,
    required TextEditingController floorController,
    required bool cityEdited,
    required bool neighborhoodEdited,
    required bool streetEdited,
    required bool forceFill,
  }) {
    _autofillTextField(
      controller: cityController,
      value: fields.city,
      wasEdited: cityEdited,
      forceFill: forceFill,
    );
    _autofillTextField(
      controller: neighborhoodController,
      value: fields.neighborhood,
      wasEdited: neighborhoodEdited,
      forceFill: forceFill,
    );
    _autofillTextField(
      controller: streetController,
      value: fields.street,
      wasEdited: streetEdited,
      forceFill: forceFill,
    );
  }

  static void _autofillTextField({
    required TextEditingController controller,
    required String? value,
    required bool wasEdited,
    required bool forceFill,
  }) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;

    final shouldFill =
        forceFill || !wasEdited || controller.text.trim().isEmpty;
    if (shouldFill) {
      controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }
}
