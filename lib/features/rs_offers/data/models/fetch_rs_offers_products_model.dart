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

FetchRsOffersProductsModel fetchRsOffersProductsModelFromJson(dynamic str) =>
    FetchRsOffersProductsModel.fromJson(str is Map<String, dynamic> ? str : Map<String, dynamic>.from(str as Map));

class FetchRsOffersProductsModel {
  List<FetchRsOffersProductsModelDataItem>? data;
  FetchRsOffersProductsModelLinks? links;
  FetchRsOffersProductsModelMeta? meta;

  FetchRsOffersProductsModel({this.data, this.links, this.meta});

  factory FetchRsOffersProductsModel.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModel(
      data: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map>()
              .map((item) => FetchRsOffersProductsModelDataItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : null,
      links: json['links'] is Map ? FetchRsOffersProductsModelLinks.fromJson(Map<String, dynamic>.from(json['links'] as Map)) : null,
      meta: json['meta'] is Map ? FetchRsOffersProductsModelMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map)) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.map((e) => e.toJson()).toList(),
        'links': links?.toJson(),
        'meta': meta?.toJson(),
      };
}

class FetchRsOffersProductsModelDataItem {
  int? id;
  String? name;
  String? description;
  num? displayPrice;
  num? originalPrice;
  String? currency;
  bool? isAvailable;
  bool? isFavorite;
  String? primaryImageUrl;
  FetchRsOffersProductsModelRestaurant? restaurant;
  FetchRsOffersProductsModelCategory? category;
  List<FetchRsOffersProductsModelActiveOffer>? activeOffers;
  String? createdAt;

  FetchRsOffersProductsModelDataItem({
    this.id,
    this.name,
    this.description,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.isAvailable,
    this.isFavorite,
    this.primaryImageUrl,
    this.restaurant,
    this.category,
    this.activeOffers,
    this.createdAt,
  });

  factory FetchRsOffersProductsModelDataItem.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelDataItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      displayPrice: _asNum(json['displayPrice']),
      originalPrice: _asNum(json['originalPrice']),
      currency: _asString(json['currency']),
      isAvailable: _asBool(json['isAvailable']),
      isFavorite: _asBool(json['isFavorite']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      restaurant: json['restaurant'] is Map
          ? FetchRsOffersProductsModelRestaurant.fromJson(Map<String, dynamic>.from(json['restaurant'] as Map))
          : null,
      category: json['category'] is Map
          ? FetchRsOffersProductsModelCategory.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
      activeOffers: json['activeOffers'] is List
          ? (json['activeOffers'] as List)
              .whereType<Map>()
              .map((item) => FetchRsOffersProductsModelActiveOffer.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : null,
      createdAt: _asString(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'displayPrice': displayPrice,
        'originalPrice': originalPrice,
        'currency': currency,
        'isAvailable': isAvailable,
        'isFavorite': isFavorite,
        'primaryImageUrl': primaryImageUrl,
        'restaurant': restaurant?.toJson(),
        'category': category?.toJson(),
        'activeOffers': activeOffers?.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
      };
}

class FetchRsOffersProductsModelRestaurant {
  int? id;
  String? name;
  String? city;
  String? district;

  FetchRsOffersProductsModelRestaurant({this.id, this.name, this.city, this.district});

  factory FetchRsOffersProductsModelRestaurant.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelRestaurant(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      city: _asString(json['city']),
      district: _asString(json['district']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'city': city, 'district': district};
}

class FetchRsOffersProductsModelCategory {
  int? id;
  String? name;

  FetchRsOffersProductsModelCategory({this.id, this.name});

  factory FetchRsOffersProductsModelCategory.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelCategory(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class FetchRsOffersProductsModelActiveOffer {
  int? id;
  String? name;
  String? offerType;
  String? discountType;
  num? discountValue;
  String? badgeText;
  String? startsAt;
  String? endsAt;
  String? urgencyTag;
  bool? isActive;

  FetchRsOffersProductsModelActiveOffer({
    this.id,
    this.name,
    this.offerType,
    this.discountType,
    this.discountValue,
    this.badgeText,
    this.startsAt,
    this.endsAt,
    this.urgencyTag,
    this.isActive,
  });

  factory FetchRsOffersProductsModelActiveOffer.fromJson(
      Map<String, dynamic> json,
      ) {
    final offerType = _asString(json['name']);

    return FetchRsOffersProductsModelActiveOffer(
      id: _asInt(json['id']),
      offerType: offerType,
      name: _getArabicName(offerType),
      discountType: _asString(json['discountType']),
      discountValue: _asNum(json['discountValue']),
      badgeText: _asString(json['badgeText']),
      startsAt: _asString(json['startsAt']),
      endsAt: _asString(json['endsAt']),
      urgencyTag: _asString(json['urgencyTag']),
      isActive: _asBool(json['isActive']),
    );
  }

  static String? _getArabicName(String? value) {
    switch (value) {
      case 'limited_time':
        return 'لفترة محدودة';

      case 'ending_soon':
        return 'ينتهي قريباً';

      case 'todays_offer':
        return 'عرض اليوم';

      default:
        return value;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': offerType,
    'discountType': discountType,
    'discountValue': discountValue,
    'badgeText': badgeText,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'urgencyTag': urgencyTag,
    'isActive': isActive,
  };
}
class FetchRsOffersProductsModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  FetchRsOffersProductsModelLinks({this.first, this.last, this.prev, this.next});

  factory FetchRsOffersProductsModelLinks.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelLinks(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asDynamic(json['prev']),
      next: _asDynamic(json['next']),
    );
  }

  Map<String, dynamic> toJson() => {'first': first, 'last': last, 'prev': prev, 'next': next};
}

class FetchRsOffersProductsModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<FetchRsOffersProductsModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  FetchRsOffersProductsModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory FetchRsOffersProductsModelMeta.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List
          ? (json['links'] as List)
              .whereType<Map>()
              .map((item) => FetchRsOffersProductsModelMetaLinksItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : null,
      path: _asString(json['path']),
      perPage: _asInt(json['per_page']),
      to: _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'from': from,
        'last_page': lastPage,
        'links': links?.map((e) => e.toJson()).toList(),
        'path': path,
        'per_page': perPage,
        'to': to,
        'total': total,
      };
}

class FetchRsOffersProductsModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  FetchRsOffersProductsModelMetaLinksItem({this.url, this.label, this.page, this.active});

  factory FetchRsOffersProductsModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return FetchRsOffersProductsModelMetaLinksItem(
      url: _asString(json['url']),
      label: _asString(json['label']),
      page: _asInt(json['page']),
      active: _asBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'label': label, 'page': page, 'active': active};
}
