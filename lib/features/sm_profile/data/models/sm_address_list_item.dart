enum SmAddressType { home, work, family }

class SmAddressListItem {
  const SmAddressListItem({
    required this.id,
    required this.label,
    required this.line1,
    required this.type,
    this.landmark,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line1;
  final String? landmark;
  final SmAddressType type;
  final bool isDefault;
}
