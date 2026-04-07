import '../../../rs_home/data/models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_suggested_products_model.dart';
import 'store_product_item.dart';

class ProductPreviewData {
  final int productId;
  final String name;
  final String restaurantName;
  final String description;
  final num? displayPrice;
  final num? originalPrice;
  final String? currency;
  final String? imageUrl;
  final bool isFavorited;

  const ProductPreviewData({
    required this.productId,
    required this.name,
    required this.restaurantName,
    required this.description,
    required this.displayPrice,
    required this.originalPrice,
    this.currency,
    this.imageUrl,
    this.isFavorited = false,
  });

  factory ProductPreviewData.fromSuggestedItem(
    RestaurantHomeSuggestedProductItem item,
  ) {
    return ProductPreviewData(
      productId: item.productId ?? 0,
      name: item.name ?? '',
      restaurantName: item.restaurantName ?? '',
      description: item.location ?? '',
      displayPrice: item.displayPrice,
      originalPrice: item.originalPrice,
      currency: item.currency,
      imageUrl: item.primaryImageUrl,
      isFavorited: false,
    );
  }

  factory ProductPreviewData.fromLatestOrderedItem(
    RestaurantHomeLatestOrderedProductItem item,
  ) {
    return ProductPreviewData(
      productId: item.productId ?? 0,
      name: item.productName ?? '',
      restaurantName: item.restaurantName ?? '',
      description: item.lastOrderedAt ?? '',
      displayPrice: item.displayPrice,
      originalPrice: item.originalPrice,
      currency: item.currency,
      imageUrl: item.primaryImageUrl,
      isFavorited: false,
    );
  }

  factory ProductPreviewData.fromStoreProduct(
    StoreProductItem item, {
    String? fallbackRestaurantName,
  }) {
    return ProductPreviewData(
      productId: item.id ?? 0,
      name: item.name,
      restaurantName: fallbackRestaurantName ?? '',
      description: item.description,
      displayPrice: item.displayPriceValue,
      originalPrice: item.oldPriceValue,
      currency: item.currency,
      imageUrl: item.imageUrl,
      isFavorited: item.isFavorited,
    );
  }
}
