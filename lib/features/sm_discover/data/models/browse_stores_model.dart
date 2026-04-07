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

BrowseStoresModel browseStoresModelFromJson(str) =>
    BrowseStoresModel.fromJson(str);

String browseStoresModelToJson(BrowseStoresModel data) =>
    json.encode(data.toJson());

BrowseStoresModelMeta browseStoresModelMetaFromJson(str) =>
    BrowseStoresModelMeta.fromJson(str);

String browseStoresModelMetaToJson(BrowseStoresModelMeta data) =>
    json.encode(data.toJson());

BrowseStoresModelMetaLinksItem browseStoresModelMetaLinksItemFromJson(str) =>
    BrowseStoresModelMetaLinksItem.fromJson(str);

String browseStoresModelMetaLinksItemToJson(
  BrowseStoresModelMetaLinksItem data,
) => json.encode(data.toJson());

BrowseStoresModelLinks browseStoresModelLinksFromJson(str) =>
    BrowseStoresModelLinks.fromJson(str);

String browseStoresModelLinksToJson(BrowseStoresModelLinks data) =>
    json.encode(data.toJson());

BrowseStoresModelDataItem browseStoresModelDataItemFromJson(str) =>
    BrowseStoresModelDataItem.fromJson(str);

String browseStoresModelDataItemToJson(BrowseStoresModelDataItem data) =>
    json.encode(data.toJson());

BrowseStoresModelDataItemOwner browseStoresModelDataItemOwnerFromJson(str) =>
    BrowseStoresModelDataItemOwner.fromJson(str);

String browseStoresModelDataItemOwnerToJson(
  BrowseStoresModelDataItemOwner data,
) => json.encode(data.toJson());

class BrowseStoresModel {
  List<BrowseStoresModelDataItem>? data;
  BrowseStoresModelLinks? links;
  BrowseStoresModelMeta? meta;

  BrowseStoresModel({this.data, this.links, this.meta});

  factory BrowseStoresModel.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (item) => BrowseStoresModelDataItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
      links: json['links'] is Map
          ? BrowseStoresModelLinks.fromJson(
              Map<String, dynamic>.from(json['links'] as Map),
            )
          : null,
      meta: json['meta'] is Map
          ? BrowseStoresModelMeta.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map),
            )
          : null,
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

class BrowseStoresModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<BrowseStoresModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  BrowseStoresModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory BrowseStoresModelMeta.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List
          ? (json['links'] as List)
                .whereType<Map>()
                .map(
                  (item) => BrowseStoresModelMetaLinksItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
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

class BrowseStoresModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  BrowseStoresModelMetaLinksItem({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory BrowseStoresModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModelMetaLinksItem(
      url: _asString(json['url']),
      label: _asString(json['label']),
      page: _asInt(json['page']),
      active: _asBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'page': page, 'active': active};
  }
}

class BrowseStoresModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  BrowseStoresModelLinks({this.first, this.last, this.prev, this.next});

  factory BrowseStoresModelLinks.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModelLinks(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asDynamic(json['prev']),
      next: _asDynamic(json['next']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}

class BrowseStoresModelDataItem {
  int? id;
  int? ownerUserId;
  BrowseStoresModelDataItemOwner? owner;
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
  bool? isFavorited;
  dynamic distanceKm;
  dynamic highestOfferDiscountValue;
  dynamic highestOffer;

  dynamic suspensionUntil;
  String? createdAt;
  String? updatedAt;

  BrowseStoresModelDataItem({
    this.id,
    this.ownerUserId,
    this.owner,
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
    this.isFavorited,
    this.distanceKm,
    this.highestOfferDiscountValue,
    this.highestOffer,
    this.createdAt,
    this.updatedAt,
  });

  factory BrowseStoresModelDataItem.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModelDataItem(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
      owner: json['owner'] is Map
          ? BrowseStoresModelDataItemOwner.fromJson(
              Map<String, dynamic>.from(json['owner'] as Map),
            )
          : null,
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
      isFavorited: _asBool(json["isFavorited"]),
      distanceKm: _asDynamic(json["distanceKm"]),
      highestOfferDiscountValue: _asDynamic(json["highestOfferDiscountValue"]),
      highestOffer: _asDynamic(json["highestOffer"]),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'owner': owner?.toJson(),
      "name": name,
      "slug": slug,
      "description": description,
      "address": address,
      "city": city,
      "neighborhood": neighborhood,
      "latitude": latitude,
      "longitude": longitude,
      "phone": phone,
      "email": email,
      "cover": cover,
      "logo": logo,
      "averageRating": averageRating,
      "totalReviews": totalReviews,
      "trustScore": trustScore,
      "warningCount": warningCount,
      "isActive": isActive,
      "isFeatured": isFeatured,
      "isFavorited": isFavorited,
      "suspensionUntil": suspensionUntil,
      "distanceKm": distanceKm,
      "highestOfferDiscountValue": highestOfferDiscountValue,
      "highestOffer": highestOffer,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class BrowseStoresModelDataItemOwner {
  int? id;
  String? name;
  String? email;
  dynamic phone;
  dynamic phoneVerifiedAt;
  dynamic moduleType;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  BrowseStoresModelDataItemOwner({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneVerifiedAt,
    this.moduleType,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BrowseStoresModelDataItemOwner.fromJson(Map<String, dynamic> json) {
    return BrowseStoresModelDataItemOwner(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asDynamic(json['phone']),
      phoneVerifiedAt: _asDynamic(json['phoneVerifiedAt']),
      moduleType: _asDynamic(json['moduleType']),
      emailVerifiedAt: _asString(json['emailVerifiedAt']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'phoneVerifiedAt': phoneVerifiedAt,
      'moduleType': moduleType,
      'emailVerifiedAt': emailVerifiedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
