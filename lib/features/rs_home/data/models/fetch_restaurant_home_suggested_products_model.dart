import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeSuggestedProductsModel fetchRestaurantHomeSuggestedProductsModelFromJson(dynamic json) =>
    FetchRestaurantHomeSuggestedProductsModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantHomeSuggestedProductsModel {
  final List<RestaurantHomeSuggestedProductItem>? suggestedProducts;

  FetchRestaurantHomeSuggestedProductsModel({this.suggestedProducts});

  factory FetchRestaurantHomeSuggestedProductsModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantHomeSuggestedProductsModel(
      suggestedProducts: json['suggestedProducts'] is List
          ? (json['suggestedProducts'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeSuggestedProductItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeSuggestedProductItem {
  final int? productId;
  final String? name;
  final double? rating;
  final num? displayPrice;
  final num? originalPrice;
  final String? currency;
  final String? primaryImageUrl;
  final String? restaurantName;
  final String? location;
  final List<String>? tags;

  RestaurantHomeSuggestedProductItem({
    this.productId,
    this.name,
    this.rating,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.primaryImageUrl,
    this.restaurantName,
    this.location,
    this.tags,
  });

  factory RestaurantHomeSuggestedProductItem.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeSuggestedProductItem(
      productId: _firstInt(json, const ['productId', 'product_id', 'id']),
      name: _firstString(json, const ['name', 'productName', 'product_name']),
      rating: _firstDouble(json, const ['rating']),
      displayPrice: _firstNum(json, const ['displayPrice', 'display_price', 'price']),
      originalPrice: _firstNum(json, const ['originalPrice', 'original_price']),
      currency: _firstString(json, const ['currency']),
      primaryImageUrl: _firstString(json, const ['primaryImageUrl', 'primary_image_url', 'imageUrl', 'image_url', 'primaryImage']),
      restaurantName: _firstString(
        json,
        const ['restaurantName', 'restaurant', 'vendorName'],
      ),
      location: _firstString(
        json,
        const ['location', 'area', 'areaName', 'cityName'],
      ),
      tags: _parseTagList(
        json['tags'] ?? json['categories'] ?? json['cuisines'],
      ),
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

double? _firstDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsDouble(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
}

List<String>? _parseTagList(dynamic value) {
  if (value is! List) return null;
  final tags = value
      .map((entry) {
        if (entry is String) return entry.trim();
        if (entry is Map) {
          final mapped = Map<String, dynamic>.from(entry);
          final text = rsHomeAsString(mapped['name']) ?? rsHomeAsString(mapped['label']);
          return text?.trim() ?? '';
        }
        return '';
      })
      .where((text) => text.isNotEmpty)
      .toList();
  return tags.isEmpty ? null : tags;
}
