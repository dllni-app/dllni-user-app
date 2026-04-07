class StoreProductItem {
  StoreProductItem({
    this.id,
    required this.name,
    required this.description,
    required this.priceText,
    required this.category,
    this.offer,
    this.oldPriceText,
    this.displayPriceValue,
    this.oldPriceValue,
    this.currency,
    this.isTop = false,
    this.imageUrl,
    this.restaurantName,
    this.offerName,
    this.offerBadgeText,
    this.offerUrgencyTag,
    this.offerDiscountType,
    this.offerDiscountValue,
    this.isOfferActive,
    this.isFavorited = false,
  });

  final int? id;
  final String name;
  final String description;
  final String priceText;
  final String? offer;
  final String category;
  final String? oldPriceText;
  final num? displayPriceValue;
  final num? oldPriceValue;
  final String? currency;
  final bool isTop;
  final String? imageUrl;
  final String? restaurantName;
  final String? offerName;
  final String? offerBadgeText;
  final String? offerUrgencyTag;
  final String? offerDiscountType;
  final num? offerDiscountValue;
  final bool? isOfferActive;
  final bool isFavorited;
}
