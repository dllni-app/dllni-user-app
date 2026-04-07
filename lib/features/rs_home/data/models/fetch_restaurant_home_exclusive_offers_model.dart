import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeExclusiveOffersModel fetchRestaurantHomeExclusiveOffersModelFromJson(dynamic json) =>
    FetchRestaurantHomeExclusiveOffersModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantHomeExclusiveOffersModel {
  final List<RestaurantHomeExclusiveOfferItem>? exclusiveOffers;

  FetchRestaurantHomeExclusiveOffersModel({this.exclusiveOffers});

  factory FetchRestaurantHomeExclusiveOffersModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantHomeExclusiveOffersModel(
      exclusiveOffers: json['exclusiveOffers'] is List
          ? (json['exclusiveOffers'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeExclusiveOfferItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeExclusiveOfferItem {
  final int? offerId;
  final int? restaurantId;
  final String? restaurantName;
  final String? offerBadgeText;
  final String? offerDescription;
  final String? discountType;
  final num? discountValue;
  final String? urgencyTag;
  final double? distanceKm;
  final String? distanceUnit;
  final String? imageUrl;
  final RestaurantHomeExclusiveOfferRestaurant? restaurant;
  final List<RestaurantHomeExclusiveOfferProduct>? products;

  RestaurantHomeExclusiveOfferItem({
    this.offerId,
    this.restaurantId,
    this.restaurantName,
    this.offerBadgeText,
    this.offerDescription,
    this.discountType,
    this.discountValue,
    this.urgencyTag,
    this.distanceKm,
    this.distanceUnit,
    this.imageUrl,
    this.restaurant,
    this.products,
  });

  factory RestaurantHomeExclusiveOfferItem.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeExclusiveOfferItem(
      offerId: _firstInt(json, const ['offerId', 'offer_id', 'id']),
      restaurantId: _firstInt(json, const ['restaurantId', 'restaurant_id']),
      restaurantName: _firstString(json, const ['restaurantName', 'restaurant_name', 'name']),
      offerBadgeText: _firstString(json, const ['offerBadgeText', 'offer_badge_text', 'badge', 'discountLabel']),
      offerDescription: _firstString(json, const ['offerDescription', 'offer_description', 'description']),
      discountType: _firstString(json, const ['discountType', 'discount_type']),
      discountValue: _firstNum(json, const ['discountValue', 'discount_value']),
      urgencyTag: _firstString(json, const ['urgencyTag', 'urgency_tag']),
      distanceKm: _firstDouble(json, const ['distanceKm', 'distance_km']),
      distanceUnit: _firstString(json, const ['distanceUnit', 'distance_unit']),
      imageUrl: _firstString(json, const ['imageUrl', 'image_url', 'primaryImage', 'primary_image']),
      restaurant: json['restaurant'] is Map
          ? RestaurantHomeExclusiveOfferRestaurant.fromJson(Map<String, dynamic>.from(json['restaurant'] as Map))
          : null,
      products: json['products'] is List
          ? (json['products'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeExclusiveOfferProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeExclusiveOfferRestaurant {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final double? averageRating;
  final int? totalReviews;
  final int? estimatedPreparationTime;
  final double? distanceKm;
  final bool? isFavorited;
  final String? imageUrl;
  final String? primaryImage;
  final String? image;

  RestaurantHomeExclusiveOfferRestaurant({
    this.id,
    this.name,
    this.description,
    this.address,
    this.averageRating,
    this.totalReviews,
    this.estimatedPreparationTime,
    this.distanceKm,
    this.isFavorited,
    this.imageUrl,
    this.primaryImage,
    this.image,
  });

  factory RestaurantHomeExclusiveOfferRestaurant.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeExclusiveOfferRestaurant(
      id: _firstInt(json, const ['id', 'restaurantId', 'restaurant_id']),
      name: _firstString(json, const ['name', 'restaurantName', 'restaurant_name']),
      description: _firstString(json, const ['description']),
      address: _firstString(json, const ['address']),
      averageRating: _firstDouble(json, const ['averageRating', 'average_rating']),
      totalReviews: _firstInt(json, const ['totalReviews', 'total_reviews']),
      estimatedPreparationTime: _firstInt(json, const ['estimatedPreparationTime', 'estimated_preparation_time']),
      distanceKm: _firstDouble(json, const ['distanceKm', 'distance_km']),
      isFavorited: _firstBool(json, const ['isFavorited', 'is_favorited']),
      imageUrl: _firstString(json, const ['imageUrl', 'image_url']),
      primaryImage: _firstString(json, const ['primaryImage', 'primary_image']),
      image: _firstString(json, const ['image']),
    );
  }
}

class RestaurantHomeExclusiveOfferProduct {
  final int? id;
  final int? restaurantId;
  final int? categoryId;
  final String? name;
  final String? description;
  final num? price;
  final num? discountedPrice;
  final bool? isFavorite;
  final bool? isAvailable;
  final bool? isAvailableNow;
  final String? availabilityMode;
  final String? unavailableUntil;
  final String? availabilityNote;
  final int? stockQuantity;
  final int? lowStockThreshold;
  final int? preparationTime;
  final bool? isFeatured;
  final String? primaryImage;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;

  RestaurantHomeExclusiveOfferProduct({
    this.id,
    this.restaurantId,
    this.categoryId,
    this.name,
    this.description,
    this.price,
    this.discountedPrice,
    this.isFavorite,
    this.isAvailable,
    this.isAvailableNow,
    this.availabilityMode,
    this.unavailableUntil,
    this.availabilityNote,
    this.stockQuantity,
    this.lowStockThreshold,
    this.preparationTime,
    this.isFeatured,
    this.primaryImage,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory RestaurantHomeExclusiveOfferProduct.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeExclusiveOfferProduct(
      id: _firstInt(json, const ['id']),
      restaurantId: _firstInt(json, const ['restaurantId', 'restaurant_id']),
      categoryId: _firstInt(json, const ['categoryId', 'category_id']),
      name: _firstString(json, const ['name']),
      description: _firstString(json, const ['description']),
      price: _firstNum(json, const ['price']),
      discountedPrice: _firstNum(json, const ['discountedPrice', 'discounted_price']),
      isFavorite: _firstBool(json, const ['isFavorite', 'is_favorite']),
      isAvailable: _firstBool(json, const ['isAvailable', 'is_available']),
      isAvailableNow: _firstBool(json, const ['isAvailableNow', 'is_available_now']),
      availabilityMode: _firstString(json, const ['availabilityMode', 'availability_mode']),
      unavailableUntil: _firstString(json, const ['unavailableUntil', 'unavailable_until']),
      availabilityNote: _firstString(json, const ['availabilityNote', 'availability_note']),
      stockQuantity: _firstInt(json, const ['stockQuantity', 'stock_quantity']),
      lowStockThreshold: _firstInt(json, const ['lowStockThreshold', 'low_stock_threshold']),
      preparationTime: _firstInt(json, const ['preparationTime', 'preparation_time']),
      isFeatured: _firstBool(json, const ['isFeatured', 'is_featured']),
      primaryImage: _firstString(json, const ['primaryImage', 'primary_image', 'imageUrl', 'image_url']),
      images: _firstStringList(json, const ['images']),
      createdAt: _firstString(json, const ['createdAt', 'created_at']),
      updatedAt: _firstString(json, const ['updatedAt', 'updated_at']),
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

bool? _firstBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsBool(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
}

List<String>? _firstStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      final list = value.map(rsHomeAsString).whereType<String>().where((e) => e.trim().isNotEmpty).toList();
      return list;
    }
  }
  return null;
}
