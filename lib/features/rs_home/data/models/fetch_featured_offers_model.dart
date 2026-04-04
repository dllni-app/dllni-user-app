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

FetchFeaturedOffersModel fetchFeaturedOffersModelFromJson(str) => FetchFeaturedOffersModel.fromJson(str);

String fetchFeaturedOffersModelToJson(FetchFeaturedOffersModel data) => json.encode(data.toJson());


FetchFeaturedOffersModelOffersItem fetchFeaturedOffersModelOffersItemFromJson(str) => FetchFeaturedOffersModelOffersItem.fromJson(str);

String fetchFeaturedOffersModelOffersItemToJson(FetchFeaturedOffersModelOffersItem data) => json.encode(data.toJson());


FetchFeaturedOffersModelOffersItemStore fetchFeaturedOffersModelOffersItemStoreFromJson(str) => FetchFeaturedOffersModelOffersItemStore.fromJson(str);

String fetchFeaturedOffersModelOffersItemStoreToJson(FetchFeaturedOffersModelOffersItemStore data) => json.encode(data.toJson());


class FetchFeaturedOffersModel {
  List<FetchFeaturedOffersModelOffersItem>? offers;

  FetchFeaturedOffersModel({
    this.offers,
  });

  factory FetchFeaturedOffersModel.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModel(
      offers: json['offers'] is List ? (json['offers'] as List).whereType<Map>().map((item) => FetchFeaturedOffersModelOffersItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offers': offers?.map((item) => item.toJson()).toList(),
    };
  }
}

class FetchFeaturedOffersModelOffersItem {
  int? id;
  int? storeId;
  FetchFeaturedOffersModelOffersItemStore? store;
  String? name;
  String? description;
  String? offerType;
  dynamic discountValue;
  int? discountPercent;
  String? startsAt;
  String? endsAt;
  bool? isActive;
  int? offerProductsCount;
  int? affectedOrdersCount;
  String? createdAt;
  String? updatedAt;

  FetchFeaturedOffersModelOffersItem({
    this.id,
    this.storeId,
    this.store,
    this.name,
    this.description,
    this.offerType,
    this.discountValue,
    this.discountPercent,
    this.startsAt,
    this.endsAt,
    this.isActive,
    this.offerProductsCount,
    this.affectedOrdersCount,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchFeaturedOffersModelOffersItem.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModelOffersItem(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      store: json['store'] is Map ? FetchFeaturedOffersModelOffersItemStore.fromJson(Map<String, dynamic>.from(json['store'] as Map)) : null,
      name: _asString(json['name']),
      description: _asDynamic(json['description']),
      offerType: _asString(json['offerType']),
      discountValue: _asDynamic(json['discountValue']),
      discountPercent: _asInt(json['discountPercent']),
      startsAt: _asDynamic(json['startsAt']),
      endsAt: _asDynamic(json['endsAt']),
      isActive: _asBool(json['isActive']),
      offerProductsCount: _asInt(json['offerProductsCount']),
      affectedOrdersCount: _asInt(json['affectedOrdersCount']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'store': store?.toJson(),
      'name': name,
      'description': description,
      'offerType': offerType,
      'discountValue': discountValue,
      'discountPercent': discountPercent,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'isActive': isActive,
      'offerProductsCount': offerProductsCount,
      'affectedOrdersCount': affectedOrdersCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class FetchFeaturedOffersModelOffersItemStore {
  int? id;
  int? ownerUserId;
  String? name;
  String? slug;
  String? description;
  String? address;
  dynamic city;
  dynamic neighborhood;
  String? latitude;
  String? longitude;
  String? phone;
  String? email;
  dynamic cover;
  dynamic logo;
  String? averageRating;
  int? totalReviews;
  int? trustScore;
  int? warningCount;
  bool? isActive;
  bool? isFeatured;
  dynamic suspensionUntil;
  String? createdAt;
  String? updatedAt;

  FetchFeaturedOffersModelOffersItemStore({
    this.id,
    this.ownerUserId,
    this.name,
    this.slug,
    this.description,
    this.address,
    this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.cover,
    this.logo,
    this.averageRating,
    this.totalReviews,
    this.trustScore,
    this.warningCount,
    this.isActive,
    this.isFeatured,
    this.suspensionUntil,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchFeaturedOffersModelOffersItemStore.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModelOffersItemStore(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asDynamic(json['city']),
      neighborhood: _asDynamic(json['neighborhood']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      cover: _asDynamic(json['cover']),
      logo: _asDynamic(json['logo']),
      averageRating: _asString(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      trustScore: _asInt(json['trustScore']),
      warningCount: _asInt(json['warningCount']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      suspensionUntil: _asDynamic(json['suspensionUntil']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'slug': slug,
      'description': description,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'cover': cover,
      'logo': logo,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'trustScore': trustScore,
      'warningCount': warningCount,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'suspensionUntil': suspensionUntil,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}