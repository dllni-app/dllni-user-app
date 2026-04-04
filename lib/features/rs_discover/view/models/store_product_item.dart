class StoreProductItem {
  StoreProductItem({
    this.id,
    required this.name,
    required this.description,
    required this.priceText,
    required this.category,
    this.oldPriceText,
    this.displayPriceValue,
    this.oldPriceValue,
    this.currency,
    this.isTop = false,
    this.imageUrl,
    this.restaurantName,
  });

  final int? id;
  final String name;
  final String description;
  final String priceText;
  final String category;
  final String? oldPriceText;
  final num? displayPriceValue;
  final num? oldPriceValue;
  final String? currency;
  final bool isTop;
  final String? imageUrl;
  final String? restaurantName;
}
