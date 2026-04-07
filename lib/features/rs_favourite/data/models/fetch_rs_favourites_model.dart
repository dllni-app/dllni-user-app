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

FetchRsFavouritesModel fetchRsFavouritesModelFromJson(str) => FetchRsFavouritesModel.fromJson(str);

String fetchRsFavouritesModelToJson(FetchRsFavouritesModel data) => json.encode(data.toJson());


FetchRsFavouritesModelMeta fetchRsFavouritesModelMetaFromJson(str) => FetchRsFavouritesModelMeta.fromJson(str);

String fetchRsFavouritesModelMetaToJson(FetchRsFavouritesModelMeta data) => json.encode(data.toJson());


FetchRsFavouritesModelMetaLinksItem fetchRsFavouritesModelMetaLinksItemFromJson(str) => FetchRsFavouritesModelMetaLinksItem.fromJson(str);

String fetchRsFavouritesModelMetaLinksItemToJson(FetchRsFavouritesModelMetaLinksItem data) => json.encode(data.toJson());


FetchRsFavouritesModelLinks fetchRsFavouritesModelLinksFromJson(str) => FetchRsFavouritesModelLinks.fromJson(str);

String fetchRsFavouritesModelLinksToJson(FetchRsFavouritesModelLinks data) => json.encode(data.toJson());


FetchRsFavouritesModelDataItem fetchRsFavouritesModelDataItemFromJson(str) => FetchRsFavouritesModelDataItem.fromJson(str);

String fetchRsFavouritesModelDataItemToJson(FetchRsFavouritesModelDataItem data) => json.encode(data.toJson());


FetchRsFavouritesModelDataItemCuisineTypesItem fetchRsFavouritesModelDataItemCuisineTypesItemFromJson(str) => FetchRsFavouritesModelDataItemCuisineTypesItem.fromJson(str);

String fetchRsFavouritesModelDataItemCuisineTypesItemToJson(FetchRsFavouritesModelDataItemCuisineTypesItem data) => json.encode(data.toJson());


FetchRsFavouritesModelDataItemListingOffer fetchRsFavouritesModelDataItemListingOfferFromJson(str) => FetchRsFavouritesModelDataItemListingOffer.fromJson(str);

String fetchRsFavouritesModelDataItemListingOfferToJson(FetchRsFavouritesModelDataItemListingOffer data) => json.encode(data.toJson());


class FetchRsFavouritesModel {
  List<FetchRsFavouritesModelDataItem>? data;
  FetchRsFavouritesModelLinks? links;
  FetchRsFavouritesModelMeta? meta;

  FetchRsFavouritesModel({
    this.data,
    this.links,
    this.meta,
  });

  factory FetchRsFavouritesModel.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModel(
      data: json['data'] is List ? (json['data'] as List).whereType<Map>().map((item) => FetchRsFavouritesModelDataItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      links: json['links'] is Map ? FetchRsFavouritesModelLinks.fromJson(Map<String, dynamic>.from(json['links'] as Map)) : null,
      meta: json['meta'] is Map ? FetchRsFavouritesModelMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map)) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((item) => item.toJson()).toList(),
      'links': links?.toJson(),
      'meta': meta?.toJson(),
    };
  }
}

class FetchRsFavouritesModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<FetchRsFavouritesModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  FetchRsFavouritesModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory FetchRsFavouritesModelMeta.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List ? (json['links'] as List).whereType<Map>().map((item) => FetchRsFavouritesModelMetaLinksItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      path: _asString(json['path']),
      perPage: _asInt(json['per_page']),
      to: _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links?.map((item) => item.toJson()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class FetchRsFavouritesModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  FetchRsFavouritesModelMetaLinksItem({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory FetchRsFavouritesModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelMetaLinksItem(
      url: _asString(json['url']),
      label: _asString(json['label']),
      page: _asInt(json['page']),
      active: _asBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'page': page,
      'active': active,
    };
  }
}

class FetchRsFavouritesModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  FetchRsFavouritesModelLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory FetchRsFavouritesModelLinks.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelLinks(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asDynamic(json['prev']),
      next: _asDynamic(json['next']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

class FetchRsFavouritesModelDataItem {
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
  num? averageRating;
  int? totalReviews;
  int? estimatedPreparationTime;
  int? minimumOrderAmount;
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
  dynamic distanceKm;
  FetchRsFavouritesModelDataItemListingOffer? listingOffer;
  List<FetchRsFavouritesModelDataItemCuisineTypesItem>? cuisineTypes;
  String? createdAt;
  String? updatedAt;

  FetchRsFavouritesModelDataItem({
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
    this.listingOffer,
    this.cuisineTypes,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchRsFavouritesModelDataItem.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelDataItem(
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
      averageRating: _asNum(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      estimatedPreparationTime: _asInt(json['estimatedPreparationTime']),
      minimumOrderAmount: _asInt(json['minimumOrderAmount']),
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
      distanceKm: _asDynamic(json['distanceKm']),
      listingOffer: json['listingOffer'] is Map ? FetchRsFavouritesModelDataItemListingOffer.fromJson(Map<String, dynamic>.from(json['listingOffer'] as Map)) : null,
      cuisineTypes: json['cuisineTypes'] is List ? (json['cuisineTypes'] as List).whereType<Map>().map((item) => FetchRsFavouritesModelDataItemCuisineTypesItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
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
      'listingOffer': listingOffer?.toJson(),
      'cuisineTypes': cuisineTypes?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class FetchRsFavouritesModelDataItemCuisineTypesItem {
  int? id;
  String? name;
  String? slug;

  FetchRsFavouritesModelDataItemCuisineTypesItem({
    this.id,
    this.name,
    this.slug,
  });

  factory FetchRsFavouritesModelDataItemCuisineTypesItem.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelDataItemCuisineTypesItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class FetchRsFavouritesModelDataItemListingOffer {
  int? id;
  String? title;
  String? discountType;
  int? discountValue;
  String? offerBadgeText;
  String? startsAt;
  String? endsAt;
  String? urgencyTag;

  FetchRsFavouritesModelDataItemListingOffer({
    this.id,
    this.title,
    this.discountType,
    this.discountValue,
    this.offerBadgeText,
    this.startsAt,
    this.endsAt,
    this.urgencyTag,
  });

  factory FetchRsFavouritesModelDataItemListingOffer.fromJson(Map<String, dynamic> json) {
    return FetchRsFavouritesModelDataItemListingOffer(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      discountType: _asString(json['discountType']),
      discountValue: _asInt(json['discountValue']),
      offerBadgeText: _asString(json['offerBadgeText']),
      startsAt: _asString(json['startsAt']),
      endsAt: _asString(json['endsAt']),
      urgencyTag: _asString(json['urgencyTag']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'discountType': discountType,
      'discountValue': discountValue,
      'offerBadgeText': offerBadgeText,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'urgencyTag': urgencyTag,
    };
  }
}