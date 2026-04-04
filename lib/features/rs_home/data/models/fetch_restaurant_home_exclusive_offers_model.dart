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
