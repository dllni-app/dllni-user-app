class RsOrderItem {
  const RsOrderItem({
    required this.id,
    required this.name,
    required this.restaurantName,
    required this.details,
    required this.unitPrice,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String restaurantName;
  final String details;
  final int unitPrice;
  final int quantity;

  int get totalPrice => unitPrice * quantity;

  RsOrderItem copyWith({
    String? id,
    String? name,
    String? restaurantName,
    String? details,
    int? unitPrice,
    int? quantity,
  }) {
    return RsOrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      restaurantName: restaurantName ?? this.restaurantName,
      details: details ?? this.details,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
