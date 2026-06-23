String? _pdString(dynamic value) => value == null ? null : '$value';

int? _pdInt(dynamic value) => value is int ? value : int.tryParse('${value ?? ''}');

num? _pdNum(dynamic value) => value is num ? value : num.tryParse('${value ?? ''}');

bool? _pdBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '${value ?? ''}'.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

FetchRestaurantProductDetailsModel fetchRestaurantProductDetailsModelFromJson(dynamic json) =>
    FetchRestaurantProductDetailsModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantProductDetailsModel {
  final RestaurantProductDetailsProduct? product;
  final List<RestaurantProductDetailsModifierGroup> modifierGroups;

  FetchRestaurantProductDetailsModel({this.product, this.modifierGroups = const []});

  factory FetchRestaurantProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantProductDetailsModel(
      product: json['product'] is Map ? RestaurantProductDetailsProduct.fromJson(Map<String, dynamic>.from(json['product'] as Map)) : null,
      modifierGroups: json['modifierGroups'] is List
          ? (json['modifierGroups'] as List)
                .whereType<Map>()
                .map((e) => RestaurantProductDetailsModifierGroup.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

class RestaurantProductDetailsProduct {
  final int? id;
  final String? name;
  final String? description;
  final num? price;
  final num? discountedPrice;
  final String? primaryImage;
  final List<String> images;
  final bool? isFavorite;
  final int cartQuantity;
  /// Public marketing URL from API (e.g. `/product/{id}`), preferred for share when present.
  final String? shareUrl;

  RestaurantProductDetailsProduct({
    this.id,
    this.name,
    this.description,
    this.price,
    this.discountedPrice,
    this.primaryImage,
    this.images = const [],
    this.isFavorite,
    this.cartQuantity = 0,
    this.shareUrl,
  });

  factory RestaurantProductDetailsProduct.fromJson(Map<String, dynamic> json) {
    return RestaurantProductDetailsProduct(
      id: _pdInt(json['id']),
      name: _pdString(json['name']),
      description: _pdString(json['description']),
      price: _pdNum(json['price']),
      discountedPrice: _pdNum(json['discountedPrice']),
      primaryImage: _pdString(json['primaryImage']),
      isFavorite: _pdBool(json['isFavorite'] ?? json['is_favorite']),
      cartQuantity: _pdInt(json['cartQuantity'] ?? json['cart_quantity']) ?? 0,
      shareUrl: _pdString(json['shareUrl'] ?? json['share_url']),
      images: json['images'] is List
          ? (json['images'] as List).map((e) => _pdString(e)?.trim() ?? '').where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }
}

class RestaurantProductDetailsModifierGroup {
  final int? id;
  final int? restaurantId;
  final String? name;
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final List<RestaurantProductDetailsModifier> modifiers;

  RestaurantProductDetailsModifierGroup({
    this.id,
    this.restaurantId,
    this.name,
    this.isRequired = false,
    this.minSelections = 0,
    this.maxSelections = 0,
    this.modifiers = const [],
  });

  factory RestaurantProductDetailsModifierGroup.fromJson(Map<String, dynamic> json) {
    return RestaurantProductDetailsModifierGroup(
      id: _pdInt(json['id']),
      restaurantId: _pdInt(json['restaurantId']),
      name: _pdString(json['name']),
      isRequired: json['isRequired'] == true,
      minSelections: _pdInt(json['minSelections']) ?? 0,
      maxSelections: _pdInt(json['maxSelections']) ?? 0,
      modifiers: json['modifiers'] is List
          ? (json['modifiers'] as List).whereType<Map>().map((e) => RestaurantProductDetailsModifier.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }
}

class RestaurantProductDetailsModifier {
  final int? id;
  final int? modifierGroupId;
  final String? name;
  final num? price;
  final int? sortOrder;

  RestaurantProductDetailsModifier({this.id, this.modifierGroupId, this.name, this.price, this.sortOrder});

  factory RestaurantProductDetailsModifier.fromJson(Map<String, dynamic> json) {
    return RestaurantProductDetailsModifier(
      id: _pdInt(json['id']),
      modifierGroupId: _pdInt(json['modifierGroupId']),
      name: _pdString(json['name']),
      price: _pdNum(json['price']),
      sortOrder: _pdInt(json['sortOrder']),
    );
  }
}
