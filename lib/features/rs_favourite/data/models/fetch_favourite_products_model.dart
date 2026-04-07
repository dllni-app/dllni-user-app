String? _fpString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return '$value';
}

int? _fpInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}');
}

num? _fpNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('${value ?? ''}');
}

bool? _fpBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '${value ?? ''}'.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

Map<String, dynamic>? _fpMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _fpMapList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

FetchFavouriteProductsModel fetchFavouriteProductsModelFromJson(dynamic json) =>
    FetchFavouriteProductsModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchFavouriteProductsModel {
  final List<FetchFavouriteProductsModelDataItem> data;
  final FetchFavouriteProductsModelLinks? links;
  final FetchFavouriteProductsModelMeta? meta;

  FetchFavouriteProductsModel({
    this.data = const [],
    this.links,
    this.meta,
  });

  factory FetchFavouriteProductsModel.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsModel(
      data: _fpMapList(json['data']).map(FetchFavouriteProductsModelDataItem.fromJson).toList(),
      links: _fpMap(json['links']) != null ? FetchFavouriteProductsModelLinks.fromJson(_fpMap(json['links'])!) : null,
      meta: _fpMap(json['meta']) != null ? FetchFavouriteProductsModelMeta.fromJson(_fpMap(json['meta'])!) : null,
    );
  }
}

class FetchFavouriteProductsModelDataItem {
  final int? id;
  final String? name;
  final String? description;
  final num? displayPrice;
  final num? originalPrice;
  final String? currency;
  final bool? isAvailable;
  final bool? isFavorite;
  final String? primaryImageUrl;
  final FetchFavouriteProductsRestaurant? restaurant;
  final FetchFavouriteProductsCategory? category;
  final List<FetchFavouriteProductsOffer> activeOffers;
  final String? createdAt;

  FetchFavouriteProductsModelDataItem({
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
    this.activeOffers = const [],
    this.createdAt,
  });

  factory FetchFavouriteProductsModelDataItem.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsModelDataItem(
      id: _fpInt(json['id']),
      name: _fpString(json['name']),
      description: _fpString(json['description']),
      displayPrice: _fpNum(json['displayPrice']),
      originalPrice: _fpNum(json['originalPrice']),
      currency: _fpString(json['currency']),
      isAvailable: _fpBool(json['isAvailable']),
      isFavorite: _fpBool(json['isFavorite'] ?? json['is_favorite']),
      primaryImageUrl: _fpString(json['primaryImageUrl']),
      restaurant: _fpMap(json['restaurant']) != null ? FetchFavouriteProductsRestaurant.fromJson(_fpMap(json['restaurant'])!) : null,
      category: _fpMap(json['category']) != null ? FetchFavouriteProductsCategory.fromJson(_fpMap(json['category'])!) : null,
      activeOffers: _fpMapList(json['activeOffers']).map(FetchFavouriteProductsOffer.fromJson).toList(),
      createdAt: _fpString(json['createdAt']),
    );
  }
}

class FetchFavouriteProductsRestaurant {
  final int? id;
  final String? name;
  final String? city;
  final String? district;

  FetchFavouriteProductsRestaurant({this.id, this.name, this.city, this.district});

  factory FetchFavouriteProductsRestaurant.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsRestaurant(
      id: _fpInt(json['id']),
      name: _fpString(json['name']),
      city: _fpString(json['city']),
      district: _fpString(json['district']),
    );
  }
}

class FetchFavouriteProductsCategory {
  final int? id;
  final String? name;

  FetchFavouriteProductsCategory({this.id, this.name});

  factory FetchFavouriteProductsCategory.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsCategory(
      id: _fpInt(json['id']),
      name: _fpString(json['name']),
    );
  }
}

class FetchFavouriteProductsOffer {
  final int? id;
  final String? name;
  final String? discountType;
  final num? discountValue;
  final String? badgeText;
  final String? startsAt;
  final String? endsAt;
  final String? urgencyTag;
  final bool? isActive;

  FetchFavouriteProductsOffer({
    this.id,
    this.name,
    this.discountType,
    this.discountValue,
    this.badgeText,
    this.startsAt,
    this.endsAt,
    this.urgencyTag,
    this.isActive,
  });

  factory FetchFavouriteProductsOffer.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsOffer(
      id: _fpInt(json['id']),
      name: _fpString(json['name']),
      discountType: _fpString(json['discountType']),
      discountValue: _fpNum(json['discountValue']),
      badgeText: _fpString(json['badgeText']),
      startsAt: _fpString(json['startsAt']),
      endsAt: _fpString(json['endsAt']),
      urgencyTag: _fpString(json['urgencyTag']),
      isActive: _fpBool(json['isActive']),
    );
  }
}

class FetchFavouriteProductsModelLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  FetchFavouriteProductsModelLinks({this.first, this.last, this.prev, this.next});

  factory FetchFavouriteProductsModelLinks.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsModelLinks(
      first: _fpString(json['first']),
      last: _fpString(json['last']),
      prev: _fpString(json['prev']),
      next: _fpString(json['next']),
    );
  }
}

class FetchFavouriteProductsModelMeta {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  FetchFavouriteProductsModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory FetchFavouriteProductsModelMeta.fromJson(Map<String, dynamic> json) {
    return FetchFavouriteProductsModelMeta(
      currentPage: _fpInt(json['current_page']),
      from: _fpInt(json['from']),
      lastPage: _fpInt(json['last_page']),
      path: _fpString(json['path']),
      perPage: _fpInt(json['per_page']),
      to: _fpInt(json['to']),
      total: _fpInt(json['total']),
    );
  }
}
