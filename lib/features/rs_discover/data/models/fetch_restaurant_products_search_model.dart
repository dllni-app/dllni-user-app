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

FetchRestaurantProductsSearchModel fetchRestaurantProductsSearchModelFromJson(
  dynamic str,
) => FetchRestaurantProductsSearchModel.fromJson(
  str is Map<String, dynamic> ? str : Map<String, dynamic>.from(str as Map),
);

class FetchRestaurantProductsSearchModel {
  List<FetchRestaurantProductsSearchModelDataItem>? data;
  FetchRestaurantProductsSearchModelLinks? links;
  FetchRestaurantProductsSearchModelMeta? meta;

  FetchRestaurantProductsSearchModel({this.data, this.links, this.meta});

  factory FetchRestaurantProductsSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (item) => FetchRestaurantProductsSearchModelDataItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
      links: json['links'] is Map
          ? FetchRestaurantProductsSearchModelLinks.fromJson(
              Map<String, dynamic>.from(json['links'] as Map),
            )
          : null,
      meta: json['meta'] is Map
          ? FetchRestaurantProductsSearchModelMeta.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data?.map((e) => e.toJson()).toList(),
    'links': links?.toJson(),
    'meta': meta?.toJson(),
  };
}

class FetchRestaurantProductsSearchModelDataItem {
  int? id;
  String? name;
  String? description;
  num? displayPrice;
  num? originalPrice;
  String? currency;
  bool? isAvailable;
  bool? isFavorite;
  bool? isMostOrdered;
  int? popularOrdersCount;
  int cartProductsCount;
  int? cartItemId;
  String? primaryImageUrl;
  FetchRestaurantProductsSearchModelRestaurant? restaurant;
  FetchRestaurantProductsSearchModelCategory? category;
  List<FetchRestaurantProductsSearchModelActiveOffer>? activeOffers;
  String? createdAt;

  FetchRestaurantProductsSearchModelDataItem({
    this.id,
    this.name,
    this.description,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.isAvailable,
    this.isFavorite,
    this.isMostOrdered,
    this.popularOrdersCount,
    this.cartProductsCount = 0,
    this.cartItemId,
    this.primaryImageUrl,
    this.restaurant,
    this.category,
    this.activeOffers,
    this.createdAt,
  });

  factory FetchRestaurantProductsSearchModelDataItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModelDataItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      displayPrice: _asNum(json['displayPrice']),
      originalPrice: _asNum(json['originalPrice']),
      currency: _asString(json['currency']),
      isAvailable: _asBool(json['isAvailable']),
      isFavorite: _asBool(json['isFavorite']),
      isMostOrdered: _asBool(json['isMostOrdered']),
      popularOrdersCount: _asInt(json['popularOrdersCount']),
      cartProductsCount: _asInt(json['cartProductsCount'] ?? json['cartQuantity'] ?? json['cart_products_count'] ?? json['cart_quantity']) ?? 0,
      cartItemId: _asInt(json['cartItemId'] ?? json['cart_item_id'] ?? json['itemId']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      restaurant: json['restaurant'] is Map
          ? FetchRestaurantProductsSearchModelRestaurant.fromJson(
              Map<String, dynamic>.from(json['restaurant'] as Map),
            )
          : null,
      category: json['category'] is Map
          ? FetchRestaurantProductsSearchModelCategory.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      activeOffers: json['activeOffers'] is List
          ? (json['activeOffers'] as List)
                .whereType<Map>()
                .map(
                  (item) =>
                      FetchRestaurantProductsSearchModelActiveOffer.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
                )
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
    'isMostOrdered': isMostOrdered,
    'popularOrdersCount': popularOrdersCount,
    'cartProductsCount': cartProductsCount,
    'cartItemId': cartItemId,
    'primaryImageUrl': primaryImageUrl,
    'restaurant': restaurant?.toJson(),
    'category': category?.toJson(),
    'activeOffers': activeOffers?.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
  };
}

class FetchRestaurantProductsSearchModelRestaurant {
  int? id;
  String? name;
  String? city;
  String? district;

  FetchRestaurantProductsSearchModelRestaurant({
    this.id,
    this.name,
    this.city,
    this.district,
  });

  factory FetchRestaurantProductsSearchModelRestaurant.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModelRestaurant(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      city: _asString(json['city']),
      district: _asString(json['district']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'district': district,
  };
}

class FetchRestaurantProductsSearchModelCategory {
  int? id;
  String? name;

  FetchRestaurantProductsSearchModelCategory({this.id, this.name});

  factory FetchRestaurantProductsSearchModelCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModelCategory(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class FetchRestaurantProductsSearchModelActiveOffer {
  int? id;
  String? title;
  String? offerType;
  String? discountType;
  num? discountValue;
  String? badgeText;
  String? startsAt;
  String? endsAt;

  FetchRestaurantProductsSearchModelActiveOffer({
    this.id,
    this.title,
    this.offerType,
    this.discountType,
    this.discountValue,
    this.startsAt,
    this.endsAt,
    this.badgeText,
  });

  factory FetchRestaurantProductsSearchModelActiveOffer.fromJson(
      Map<String, dynamic> json,
      ) {
    final offerType = _asString(json['title']);

    return FetchRestaurantProductsSearchModelActiveOffer(
      id: _asInt(json['id']),
      offerType: offerType,
      title: _getArabicTitle(offerType),
      badgeText: _asString(json['badgeText']),
      discountType: _asString(json['discountType']),
      discountValue: _asNum(json['discountValue']),
      startsAt: _asString(json['startsAt']),
      endsAt: _asString(json['endsAt']),
    );
  }

  static String? _getArabicTitle(String? value) {
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
    'title': offerType,
    'badgeText': badgeText,
    'discountType': discountType,
    'discountValue': discountValue,
    'startsAt': startsAt,
    'endsAt': endsAt,
  };
}

class FetchRestaurantProductsSearchModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  FetchRestaurantProductsSearchModelLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory FetchRestaurantProductsSearchModelLinks.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModelLinks(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asDynamic(json['prev']),
      next: _asDynamic(json['next']),
    );
  }

  Map<String, dynamic> toJson() => {
    'first': first,
    'last': last,
    'prev': prev,
    'next': next,
  };
}

class FetchRestaurantProductsSearchModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  FetchRestaurantProductsSearchModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory FetchRestaurantProductsSearchModelMeta.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchRestaurantProductsSearchModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
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
    'per_page': perPage,
    'path': path,
    'to': to,
    'total': total,
  };
}
