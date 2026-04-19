class GroupOrderFoodRow {
  final int? itemId;
  final int? productId;
  final String name;
  final int quantity;
  final String type;
  final String subtitle;
  final String? imageUrl;

  const GroupOrderFoodRow({
    required this.itemId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.type,
    required this.subtitle,
    required this.imageUrl,
  });
}
