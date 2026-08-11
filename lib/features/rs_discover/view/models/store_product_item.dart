class StoreProductItem {
  StoreProductItem({
    this.id,
    required this.name,
    required this.description,
    required this.priceText,
    required this.category,
    String? offer,
    this.oldPriceText,
    num? displayPriceValue,
    num? oldPriceValue,
    this.currency,
    this.isTop = false,
    this.cartProductsCount = 0,
    this.cartItemId,
    this.imageUrl,
    this.restaurantName,
    String? offerName,
    String? offerBadgeText,
    String? offerUrgencyTag,
    String? offerDiscountType,
    num? offerDiscountValue,
    bool? isOfferActive,
    this.isFavorited = false,
  }) : displayPriceValue = displayPriceValue,
       oldPriceValue = oldPriceValue,
       offer = offer ?? _fallbackOfferLabel(displayPriceValue, oldPriceValue),
       offerName = offerName,
       offerBadgeText = offerBadgeText ??
           _fallbackOfferLabel(displayPriceValue, oldPriceValue),
       offerUrgencyTag = offerUrgencyTag ??
           _fallbackOfferUrgency(displayPriceValue, oldPriceValue),
       offerDiscountType = offerDiscountType,
       offerDiscountValue = offerDiscountValue,
       isOfferActive = isOfferActive ??
           _hasDiscountedPrice(displayPriceValue, oldPriceValue);

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
  final int cartProductsCount;
  final int? cartItemId;
  final String? imageUrl;
  final String? restaurantName;
  final String? offerName;
  final String? offerBadgeText;
  final String? offerUrgencyTag;
  final String? offerDiscountType;
  final num? offerDiscountValue;
  final bool? isOfferActive;
  final bool isFavorited;

  bool get hasActiveOfferPricing {
    final type = (offerDiscountType ?? '').trim().toLowerCase();
    final value = offerDiscountValue;
    return isOfferActive == true &&
        value != null &&
        value > 0 &&
        (type == 'percentage' || type == 'fixed_amount');
  }

  bool get _hasServerDiscount {
    final display = displayPriceValue;
    final original = oldPriceValue;
    return display != null && original != null && original > display;
  }

  num? get resolvedDisplayPriceValue {
    final base = displayPriceValue;
    if (base == null || _hasServerDiscount || !hasActiveOfferPricing) {
      return base;
    }

    final value = offerDiscountValue!;
    final type = offerDiscountType!.trim().toLowerCase();
    num discounted;

    if (type == 'percentage') {
      final percentage = value.clamp(0, 100);
      discounted = base * (1 - (percentage / 100));
    } else {
      discounted = base - value;
    }

    return discounted < 0 ? 0 : discounted;
  }

  num? get resolvedOldPriceValue {
    if (_hasServerDiscount) return oldPriceValue;

    final base = displayPriceValue;
    final resolved = resolvedDisplayPriceValue;
    if (base != null && resolved != null && resolved < base) {
      return base;
    }

    return null;
  }
}

bool _hasDiscountedPrice(num? displayPrice, num? originalPrice) {
  return displayPrice != null &&
      originalPrice != null &&
      originalPrice > displayPrice;
}

String? _fallbackOfferLabel(num? displayPrice, num? originalPrice) {
  return _hasDiscountedPrice(displayPrice, originalPrice) ? 'خصم' : null;
}

String? _fallbackOfferUrgency(num? displayPrice, num? originalPrice) {
  return _hasDiscountedPrice(displayPrice, originalPrice) ? 'عرض' : null;
}
