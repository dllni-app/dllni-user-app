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


FetchFeaturedOffersModelRestaurant fetchFeaturedOffersModelRestaurantFromJson(str) =>
    FetchFeaturedOffersModelRestaurant.fromJson(str);

String fetchFeaturedOffersModelRestaurantToJson(FetchFeaturedOffersModelRestaurant data) =>
    json.encode(data.toJson());


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
  int? offerId;
  int? restaurantId;
  String? restaurantName;
  String? offerBadgeText;
  String? offerDescription;
  String? discountType;
  num? discountValue;
  String? urgencyTag;
  double? distanceKm;
  String? distanceUnit;
  String? imageUrl;
  FetchFeaturedOffersModelRestaurant? restaurant;
  List<FetchFeaturedOffersModelProduct>? products;

  FetchFeaturedOffersModelOffersItem({
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

  factory FetchFeaturedOffersModelOffersItem.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModelOffersItem(
      offerId: _asInt(json['offerId']),
      restaurantId: _asInt(json['restaurantId']),
      restaurantName: _asString(json['restaurantName']),
      offerBadgeText: _asString(json['offerBadgeText']),
      offerDescription: _asString(json['offerDescription']),
      discountType: _asString(json['discountType']),
      discountValue: _asNum(json['discountValue']),
      urgencyTag: _asString(json['urgencyTag']),
      distanceKm: _asDouble(json['distanceKm']),
      distanceUnit: _asString(json['distanceUnit']),
      imageUrl: _asString(json['imageUrl']),
      restaurant: json['restaurant'] is Map
          ? FetchFeaturedOffersModelRestaurant.fromJson(
              Map<String, dynamic>.from(json['restaurant'] as Map),
            )
          : null,
      products: json['products'] is List
          ? (json['products'] as List)
              .whereType<Map>()
              .map(
                (item) => FetchFeaturedOffersModelProduct.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'offerBadgeText': offerBadgeText,
      'offerDescription': offerDescription,
      'discountType': discountType,
      'discountValue': discountValue,
      'urgencyTag': urgencyTag,
      'distanceKm': distanceKm,
      'distanceUnit': distanceUnit,
      'imageUrl': imageUrl,
      'restaurant': restaurant?.toJson(),
      'products': products?.map((item) => item.toJson()).toList(),
    };
  }
}

class FetchFeaturedOffersModelRestaurant {
  int? id;
  int? userId;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? district;
  String? locationDetails;
  double? latitude;
  double? longitude;
  String? phone;
  String? whatsappNumber;
  String? whatsapp;
  String? email;
  String? instagramUsername;
  String? instagram;
  String? facebookPageName;
  String? face;
  double? averageRating;
  int? totalReviews;
  int? estimatedPreparationTime;
  num? minimumOrderAmount;
  String? priceRange;
  int? reputationScore;
  int? warningCount;
  int? visibilityScore;
  bool? manualVisibilityOverride;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;
  dynamic suspensionUntil;
  String? primaryImage;
  String? image;
  String? imageUrl;
  String? banner;
  List<dynamic>? images;
  double? lat;
  double? long;
  double? distanceKm;
  String? createdAt;
  String? updatedAt;

  FetchFeaturedOffersModelRestaurant({
    this.id,
    this.userId,
    this.name,
    this.slug,
    this.description,
    this.address,
    this.city,
    this.district,
    this.locationDetails,
    this.latitude,
    this.longitude,
    this.phone,
    this.whatsappNumber,
    this.whatsapp,
    this.email,
    this.instagramUsername,
    this.instagram,
    this.facebookPageName,
    this.face,
    this.averageRating,
    this.totalReviews,
    this.estimatedPreparationTime,
    this.minimumOrderAmount,
    this.priceRange,
    this.reputationScore,
    this.warningCount,
    this.visibilityScore,
    this.manualVisibilityOverride,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
    this.suspensionUntil,
    this.primaryImage,
    this.image,
    this.imageUrl,
    this.banner,
    this.images,
    this.lat,
    this.long,
    this.distanceKm,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchFeaturedOffersModelRestaurant.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModelRestaurant(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      district: _asString(json['district']),
      locationDetails: _asString(json['locationDetails']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      whatsappNumber: _asString(json['whatsappNumber']),
      whatsapp: _asString(json['whatsapp']),
      email: _asString(json['email']),
      instagramUsername: _asString(json['instagramUsername']),
      instagram: _asString(json['instagram']),
      facebookPageName: _asString(json['facebookPageName']),
      face: _asString(json['face']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      estimatedPreparationTime: _asInt(json['estimatedPreparationTime']),
      minimumOrderAmount: _asNum(json['minimumOrderAmount']),
      priceRange: _asString(json['priceRange']),
      reputationScore: _asInt(json['reputationScore']),
      warningCount: _asInt(json['warningCount']),
      visibilityScore: _asInt(json['visibilityScore']),
      manualVisibilityOverride: _asBool(json['manualVisibilityOverride']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
      suspensionUntil: _asDynamic(json['suspensionUntil']),
      primaryImage: _asString(json['primaryImage']),
      image: _asString(json['image']),
      imageUrl: _asString(json['imageUrl']),
      banner: _asString(json['banner']),
      images: _asDynamicList(json['images']),
      lat: _asDouble(json['lat']),
      long: _asDouble(json['long']),
      distanceKm: _asDouble(json['distanceKm']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'slug': slug,
      'description': description,
      'address': address,
      'city': city,
      'district': district,
      'locationDetails': locationDetails,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'whatsapp': whatsapp,
      'email': email,
      'instagramUsername': instagramUsername,
      'instagram': instagram,
      'facebookPageName': facebookPageName,
      'face': face,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'estimatedPreparationTime': estimatedPreparationTime,
      'minimumOrderAmount': minimumOrderAmount,
      'priceRange': priceRange,
      'reputationScore': reputationScore,
      'warningCount': warningCount,
      'visibilityScore': visibilityScore,
      'manualVisibilityOverride': manualVisibilityOverride,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
      'suspensionUntil': suspensionUntil,
      'primaryImage': primaryImage,
      'image': image,
      'imageUrl': imageUrl,
      'banner': banner,
      'images': images,
      'lat': lat,
      'long': long,
      'distanceKm': distanceKm,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class FetchFeaturedOffersModelProduct {
  int? id;
  int? restaurantId;
  int? categoryId;
  String? name;
  String? description;
  num? price;
  num? discountedPrice;
  bool? isFavorite;
  bool? isAvailable;
  bool? isAvailableNow;
  String? availabilityMode;
  dynamic unavailableUntil;
  String? availabilityNote;
  int? stockQuantity;
  int? lowStockThreshold;
  int? preparationTime;
  bool? isFeatured;
  String? primaryImage;
  List<dynamic>? images;
  String? createdAt;
  String? updatedAt;

  FetchFeaturedOffersModelProduct({
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

  factory FetchFeaturedOffersModelProduct.fromJson(Map<String, dynamic> json) {
    return FetchFeaturedOffersModelProduct(
      id: _asInt(json['id']),
      restaurantId: _asInt(json['restaurantId']),
      categoryId: _asInt(json['categoryId']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      price: _asNum(json['price']),
      discountedPrice: _asNum(json['discountedPrice']),
      isFavorite: _asBool(json['isFavorite']),
      isAvailable: _asBool(json['isAvailable']),
      isAvailableNow: _asBool(json['isAvailableNow']),
      availabilityMode: _asString(json['availabilityMode']),
      unavailableUntil: _asDynamic(json['unavailableUntil']),
      availabilityNote: _asString(json['availabilityNote']),
      stockQuantity: _asInt(json['stockQuantity']),
      lowStockThreshold: _asInt(json['lowStockThreshold']),
      preparationTime: _asInt(json['preparationTime']),
      isFeatured: _asBool(json['isFeatured']),
      primaryImage: _asString(json['primaryImage']),
      images: _asDynamicList(json['images']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'isFavorite': isFavorite,
      'isAvailable': isAvailable,
      'isAvailableNow': isAvailableNow,
      'availabilityMode': availabilityMode,
      'unavailableUntil': unavailableUntil,
      'availabilityNote': availabilityNote,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'preparationTime': preparationTime,
      'isFeatured': isFeatured,
      'primaryImage': primaryImage,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}