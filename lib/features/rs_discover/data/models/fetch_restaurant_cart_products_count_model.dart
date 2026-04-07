int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

FetchRestaurantCartProductsCountModel fetchRestaurantCartProductsCountModelFromJson(
  dynamic json,
) => FetchRestaurantCartProductsCountModel.fromJson(
  json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map),
);

class FetchRestaurantCartProductsCountModel {
  final int productsCount;

  const FetchRestaurantCartProductsCountModel({
    required this.productsCount,
  });

  factory FetchRestaurantCartProductsCountModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantCartProductsCountModel(
      productsCount: _asInt(json['productsCount']) ?? 0,
    );
  }
}
