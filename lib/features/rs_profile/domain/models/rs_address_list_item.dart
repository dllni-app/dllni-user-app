enum RsAddressType { home, work, family }

class RsAddressListItem {
  const RsAddressListItem({
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
  final RsAddressType type;
  final bool isDefault;
}
