import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeLatestOrderedProductsModel fetchRestaurantHomeLatestOrderedProductsModelFromJson(dynamic json) =>
    FetchRestaurantHomeLatestOrderedProductsModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantHomeLatestOrderedProductsModel {
  final List<RestaurantHomeLatestOrderedProductItem>? latestOrderedProducts;

  FetchRestaurantHomeLatestOrderedProductsModel({this.latestOrderedProducts});

  factory FetchRestaurantHomeLatestOrderedProductsModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantHomeLatestOrderedProductsModel(
      latestOrderedProducts: json['latestOrderedProducts'] is List
          ? (json['latestOrderedProducts'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeLatestOrderedProductItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeLatestOrderedProductItem {
  final int? productId;
  final String? productName;
  final int? restaurantId;
  final String? restaurantName;
  final num? displayPrice;
  final num? originalPrice;
  final num? lastOrderedLineUnitPrice;
  final String? currency;
  final String? primaryImageUrl;
  final int? lastOrderId;
  final String? lastOrderedAt;

  RestaurantHomeLatestOrderedProductItem({
    this.productId,
    this.productName,
    this.restaurantId,
    this.restaurantName,
    this.displayPrice,
    this.originalPrice,
    this.lastOrderedLineUnitPrice,
    this.currency,
    this.primaryImageUrl,
    this.lastOrderId,
    this.lastOrderedAt,
  });

  factory RestaurantHomeLatestOrderedProductItem.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeLatestOrderedProductItem(
      productId: _firstInt(json, const ['productId', 'product_id', 'id']),
      productName: _firstString(json, const ['productName', 'product_name', 'name']),
      restaurantId: _firstInt(json, const ['restaurantId', 'restaurant_id']),
      restaurantName: _firstString(json, const ['restaurantName', 'restaurant_name']),
      displayPrice: _firstNum(json, const ['displayPrice', 'display_price', 'price']),
      originalPrice: _firstNum(json, const ['originalPrice', 'original_price']),
      lastOrderedLineUnitPrice: _firstNum(json, const ['lastOrderedLineUnitPrice', 'last_ordered_line_unit_price']),
      currency: _firstString(json, const ['currency']),
      primaryImageUrl: _firstString(json, const ['primaryImageUrl', 'primary_image_url', 'imageUrl', 'image_url', 'primaryImage']),
      lastOrderId: _firstInt(json, const ['lastOrderId', 'last_order_id']),
      lastOrderedAt: _firstString(json, const ['lastOrderedAt', 'last_ordered_at']),
    );
  }
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsString(json[key]);
    if (parsed != null && parsed.trim().isNotEmpty) return parsed;
  }
  return null;
}

int? _firstInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsInt(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
}

num? _firstNum(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsNum(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
}
