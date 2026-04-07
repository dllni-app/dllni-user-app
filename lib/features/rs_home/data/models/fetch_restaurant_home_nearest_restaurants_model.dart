import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeNearestRestaurantsModel fetchRestaurantHomeNearestRestaurantsModelFromJson(dynamic json) =>
    FetchRestaurantHomeNearestRestaurantsModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantHomeNearestRestaurantsModel {
  final List<RestaurantHomeNearestRestaurantItem>? nearestRestaurants;

  FetchRestaurantHomeNearestRestaurantsModel({this.nearestRestaurants});

  factory FetchRestaurantHomeNearestRestaurantsModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantHomeNearestRestaurantsModel(
      nearestRestaurants: json['nearestRestaurants'] is List
          ? (json['nearestRestaurants'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeNearestRestaurantItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeNearestRestaurantItem {
  final int? id;
  final String? name;
  final String? slug;
  final double? rating;
  final String? primaryImageUrl;
  final List<String>? cuisineNames;
  final String? cuisineSummary;
  final double? distanceKm;
  final String? distanceUnit;
  final int? estimatedDeliveryMinutesMin;
  final int? estimatedDeliveryMinutesMax;
  final String? discountOfferBadge;
  final bool? isMostRequested;
  final int? popularOrdersCount;
  final bool? isFavorited;
  final num? deliveryFee;
  final bool? isFreeDelivery;
  final String? currency;

  RestaurantHomeNearestRestaurantItem({
    this.id,
    this.name,
    this.slug,
    this.rating,
    this.primaryImageUrl,
    this.cuisineNames,
    this.cuisineSummary,
    this.distanceKm,
    this.distanceUnit,
    this.estimatedDeliveryMinutesMin,
    this.estimatedDeliveryMinutesMax,
    this.discountOfferBadge,
    this.isMostRequested,
    this.popularOrdersCount,
    this.isFavorited,
    this.deliveryFee,
    this.isFreeDelivery,
    this.currency,
  });

  factory RestaurantHomeNearestRestaurantItem.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeNearestRestaurantItem(
      id: _firstInt(json, const ['id']),
      name: _firstString(json, const ['name']),
      slug: _firstString(json, const ['slug']),
      rating: _firstDouble(json, const ['rating', 'averageRating', 'average_rating']),
      primaryImageUrl: _firstString(json, const ['primaryImageUrl', 'primary_image_url', 'imageUrl', 'image_url', 'primaryImage']),
      cuisineNames: json['cuisineNames'] is List ? (json['cuisineNames'] as List).map((e) => '$e').toList() : null,
      cuisineSummary: _firstString(json, const ['cuisineSummary', 'cuisine_summary', 'description']),
      distanceKm: _firstDouble(json, const ['distanceKm', 'distance_km']),
      distanceUnit: _firstString(json, const ['distanceUnit', 'distance_unit']),
      estimatedDeliveryMinutesMin: _firstInt(json, const ['estimatedDeliveryMinutesMin', 'estimated_delivery_minutes_min']),
      estimatedDeliveryMinutesMax: _firstInt(json, const ['estimatedDeliveryMinutesMax', 'estimated_delivery_minutes_max', 'estimatedPreparationTime']),
      discountOfferBadge: _firstString(json, const ['discountOfferBadge', 'discount_offer_badge']),
      isMostRequested: _firstBool(json, const ['isMostRequested', 'is_most_requested']),
      popularOrdersCount: _firstInt(json, const ['popularOrdersCount', 'popular_orders_count', 'totalReviews']),
      isFavorited: _firstBool(json, const ['isFavorited', 'is_favorited']),
      deliveryFee: _firstNum(json, const ['deliveryFee', 'delivery_fee']),
      isFreeDelivery: _firstBool(json, const ['isFreeDelivery', 'is_free_delivery']),
      currency: _firstString(json, const ['currency']),
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

double? _firstDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsDouble(json[key]);
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

bool? _firstBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = rsHomeAsBool(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
}
