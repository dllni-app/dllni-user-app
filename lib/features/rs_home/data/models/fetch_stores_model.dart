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

FetchStoresModel fetchStoresModelFromJson(str) => FetchStoresModel.fromJson(str);

String fetchStoresModelToJson(FetchStoresModel data) => json.encode(data.toJson());


FetchStoresModelMeta fetchStoresModelMetaFromJson(str) => FetchStoresModelMeta.fromJson(str);

String fetchStoresModelMetaToJson(FetchStoresModelMeta data) => json.encode(data.toJson());


FetchStoresModelMetaLinksItem fetchStoresModelMetaLinksItemFromJson(str) => FetchStoresModelMetaLinksItem.fromJson(str);

String fetchStoresModelMetaLinksItemToJson(FetchStoresModelMetaLinksItem data) => json.encode(data.toJson());


FetchStoresModelLinks fetchStoresModelLinksFromJson(str) => FetchStoresModelLinks.fromJson(str);

String fetchStoresModelLinksToJson(FetchStoresModelLinks data) => json.encode(data.toJson());


FetchStoresModelDataItem fetchStoresModelDataItemFromJson(str) => FetchStoresModelDataItem.fromJson(str);

String fetchStoresModelDataItemToJson(FetchStoresModelDataItem data) => json.encode(data.toJson());


FetchStoresModelDataItemOwner fetchStoresModelDataItemOwnerFromJson(str) => FetchStoresModelDataItemOwner.fromJson(str);

String fetchStoresModelDataItemOwnerToJson(FetchStoresModelDataItemOwner data) => json.encode(data.toJson());


class FetchStoresModel {
  List<FetchStoresModelDataItem>? data;
  FetchStoresModelLinks? links;
  FetchStoresModelMeta? meta;

  FetchStoresModel({
    this.data,
    this.links,
    this.meta,
  });

  factory FetchStoresModel.fromJson(Map<String, dynamic> json) {
    return FetchStoresModel(
      data: json['data'] is List ? (json['data'] as List).whereType<Map>().map((item) => FetchStoresModelDataItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      links: json['links'] is Map ? FetchStoresModelLinks.fromJson(Map<String, dynamic>.from(json['links'] as Map)) : null,
      meta: json['meta'] is Map ? FetchStoresModelMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map)) : null,
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

class FetchStoresModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<FetchStoresModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  FetchStoresModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory FetchStoresModelMeta.fromJson(Map<String, dynamic> json) {
    return FetchStoresModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List ? (json['links'] as List).whereType<Map>().map((item) => FetchStoresModelMetaLinksItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
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

class FetchStoresModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  FetchStoresModelMetaLinksItem({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory FetchStoresModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return FetchStoresModelMetaLinksItem(
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

class FetchStoresModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  FetchStoresModelLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory FetchStoresModelLinks.fromJson(Map<String, dynamic> json) {
    return FetchStoresModelLinks(
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

class FetchStoresModelDataItem {
  int? id;
  int? ownerUserId;
  FetchStoresModelDataItemOwner? owner;
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

  FetchStoresModelDataItem({
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
    this.createdAt,
    this.updatedAt,
  });

  factory FetchStoresModelDataItem.fromJson(Map<String, dynamic> json) {
    return FetchStoresModelDataItem(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
      owner: json['owner'] is Map ? FetchStoresModelDataItemOwner.fromJson(Map<String, dynamic>.from(json['owner'] as Map)) : null,
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
      'owner': owner?.toJson(),
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

class FetchStoresModelDataItemOwner {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? moduleType;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  FetchStoresModelDataItemOwner({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.moduleType,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchStoresModelDataItemOwner.fromJson(Map<String, dynamic> json) {
    return FetchStoresModelDataItemOwner(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      moduleType: _asString(json['moduleType']),
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
      'moduleType': moduleType,
      'emailVerifiedAt': emailVerifiedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}