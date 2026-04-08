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
  final AddressType type;
  final bool isDefault;
}
