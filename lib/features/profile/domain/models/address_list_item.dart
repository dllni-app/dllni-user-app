enum AddressType { home, work, family }

class AddressListItem {
  const AddressListItem({
    required this.id,
    required this.label,
    required this.line1,
    required this.type,
    this.mobile,
    this.city,
    this.neighborhood,
    this.street,
    this.building,
    this.floor,
    this.directions,
    this.landmark,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line1;
  final String? mobile;
  final String? city;
  final String? neighborhood;
  final String? street;
  final String? building;
  final String? floor;
  final String? directions;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final AddressType type;
  final bool isDefault;

  bool get hasCompleteServiceLocation {
    final parsedId = int.tryParse(id);
    return parsedId != null &&
        parsedId > 0 &&
        label.trim().isNotEmpty &&
        line1.trim().isNotEmpty &&
        (neighborhood?.trim().isNotEmpty ?? false) &&
        latitude != null &&
        longitude != null;
  }
}
