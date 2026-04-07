import 'dart:convert';

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

List<dynamic>? _asDynamicList(dynamic value) {
  if (value is! List) return null;
  return value.map(_asDynamic).toList();
}

dynamic _asDynamic(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map(_asDynamic).toList();
  }
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((key, nestedValue) {
      map['$key'] = _asDynamic(nestedValue);
    });
    return map;
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  return value.toString();
}

GetNearbyStoresModel getNearbyStoresModelFromJson(str) =>
    GetNearbyStoresModel.fromJson(str);

String getNearbyStoresModelToJson(GetNearbyStoresModel data) =>
    json.encode(data.toJson());

GetNearbyStoresModelStoresItem getNearbyStoresModelStoresItemFromJson(str) =>
    GetNearbyStoresModelStoresItem.fromJson(str);

String getNearbyStoresModelStoresItemToJson(
  GetNearbyStoresModelStoresItem data,
) => json.encode(data.toJson());

class GetNearbyStoresModel {
  List<GetNearbyStoresModelStoresItem>? stores;

  GetNearbyStoresModel({this.stores});

  factory GetNearbyStoresModel.fromJson(Map<String, dynamic> json) {
    return GetNearbyStoresModel(
      stores: json['stores'] is List
          ? (json['stores'] as List)
                .whereType<Map>()
                .map(
                  (item) => GetNearbyStoresModelStoresItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'stores': stores?.map((item) => item.toJson()).toList()};
  }
}

class GetNearbyStoresModelStoresItem {
  int? id;
  String? name;
  String? slug;
  String? cover;
  String? logo;
  num? rating;
  List<String?>? categoryNames;
  String? categorySummary;
  num? distanceKm;
  String? distanceUnit;
  int? estimatedDeliveryMinutesMin;
  int? estimatedDeliveryMinutesMax;
  String? discountOfferBadge;
  bool? isMostRequested;
  num? popularOrdersCount;
  bool? isFavorited;
  dynamic deliveryFee;
  bool? isFreeDelivery;
  String? currency;

  GetNearbyStoresModelStoresItem({
    this.id,
    this.name,
    this.slug,
    this.cover,
    this.logo,
    this.rating,
    this.categoryNames,
    this.categorySummary,
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

  factory GetNearbyStoresModelStoresItem.fromJson(Map<String, dynamic> json) {
    return GetNearbyStoresModelStoresItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      cover: _asString(json['cover']),
      logo: _asString(json['logo']),
      rating: _asNum(json['rating']),
      categoryNames: json['categoryNames'] is List
          ? (json['categoryNames'] as List).map((e) => _asString(e)).toList()
          : null,
      categorySummary: _asString(json['categorySummary']),
      distanceKm: _asNum(json['distanceKm']),
      distanceUnit: _asString(json['distanceUnit']),
      estimatedDeliveryMinutesMin: _asInt(
        json['estimatedDeliveryMinutesMin'],
      ),
      estimatedDeliveryMinutesMax: _asInt(
        json['estimatedDeliveryMinutesMax'],
      ),
      discountOfferBadge: _asString(json['discountOfferBadge']),
      isMostRequested: _asBool(json['isMostRequested']),
      popularOrdersCount: _asNum(json['popularOrdersCount']),
      isFavorited: _asBool(json['isFavorited']),
      deliveryFee: _asDynamic(json['deliveryFee']),
      isFreeDelivery: _asBool(json['isFreeDelivery']),
      currency: _asString(json['currency']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'cover': cover,
      'logo': logo,
      'rating': rating,
      'categoryNames': categoryNames,
      'categorySummary': categorySummary,
      'distanceKm': distanceKm,
      'distanceUnit': distanceUnit,
      'estimatedDeliveryMinutesMin': estimatedDeliveryMinutesMin,
      'estimatedDeliveryMinutesMax': estimatedDeliveryMinutesMax,
      'discountOfferBadge': discountOfferBadge,
      'isMostRequested': isMostRequested,
      'popularOrdersCount': popularOrdersCount,
      'isFavorited': isFavorited,
      'deliveryFee': deliveryFee,
      'isFreeDelivery': isFreeDelivery,
      'currency': currency,
    };
  }
}
