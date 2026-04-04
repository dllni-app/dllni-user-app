import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeCategoryProductsModel
fetchRestaurantHomeCategoryProductsModelFromJson(dynamic json) =>
    FetchRestaurantHomeCategoryProductsModel.fromJson(
      Map<String, dynamic>.from(json as Map),
    );

class FetchRestaurantHomeCategoryProductsModel {
  final List<RestaurantHomeCategoryProductsItem> products;

  FetchRestaurantHomeCategoryProductsModel({this.products = const []});

  factory FetchRestaurantHomeCategoryProductsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic listDynamic =
        json['products'] ?? json['data'] ?? json['items'] ?? const <dynamic>[];
    final list = listDynamic is List ? listDynamic : const <dynamic>[];
    return FetchRestaurantHomeCategoryProductsModel(
      products: list
          .whereType<Map>()
          .map(
            (e) => RestaurantHomeCategoryProductsItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class RestaurantHomeCategoryProductsItem {
  final int? productId;
  final String? name;
  final String? description;
  final num? displayPrice;
  final num? originalPrice;
  final String? currency;
  final String? primaryImageUrl;
  final String? restaurantName;

  RestaurantHomeCategoryProductsItem({
    this.productId,
    this.name,
    this.description,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.primaryImageUrl,
    this.restaurantName,
  });

  factory RestaurantHomeCategoryProductsItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return RestaurantHomeCategoryProductsItem(
      productId: _firstInt(json, const ['productId', 'product_id', 'id']),
      name: _firstString(json, const ['name', 'productName', 'product_name']),
      description: _firstString(json, const ['description', 'details']),
      displayPrice: _firstNum(json, const [
        'displayPrice',
        'display_price',
        'price',
      ]),
      originalPrice: _firstNum(json, const ['originalPrice', 'original_price']),
      currency: _firstString(json, const ['currency']),
      primaryImageUrl: _firstString(json, const [
        'primaryImageUrl',
        'primary_image_url',
        'imageUrl',
        'image_url',
        'primaryImage',
      ]),
      restaurantName: _firstString(json, const [
        'restaurantName',
        'restaurant_name',
        'restaurant',
      ]),
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
