import 'dart:convert';

BrowseProductsModelDataItem browseProductsModelDataItemFromJson(str) =>
    BrowseProductsModelDataItem.fromJson(str);

BrowseProductsModelDataItemImage browseProductsModelDataItemImageFromJson(
  str,
) => BrowseProductsModelDataItemImage.fromJson(str);

BrowseProductsModelDataItemImagesItem
browseProductsModelDataItemImagesItemFromJson(str) =>
    BrowseProductsModelDataItemImagesItem.fromJson(str);

String browseProductsModelDataItemImagesItemToJson(
  BrowseProductsModelDataItemImagesItem data,
) => json.encode(data.toJson());

String browseProductsModelDataItemImageToJson(
  BrowseProductsModelDataItemImage data,
) => json.encode(data.toJson());

BrowseProductsModelDataItemStore browseProductsModelDataItemStoreFromJson(
  str,
) => BrowseProductsModelDataItemStore.fromJson(str);

String browseProductsModelDataItemStoreToJson(
  BrowseProductsModelDataItemStore data,
) => json.encode(data.toJson());

String browseProductsModelDataItemToJson(BrowseProductsModelDataItem data) =>
    json.encode(data.toJson());

BrowseProductsModel browseProductsModelFromJson(str) =>
    BrowseProductsModel.fromJson(str);

BrowseProductsModelLinks browseProductsModelLinksFromJson(str) =>
    BrowseProductsModelLinks.fromJson(str);

String browseProductsModelLinksToJson(BrowseProductsModelLinks data) =>
    json.encode(data.toJson());

BrowseProductsModelMeta browseProductsModelMetaFromJson(str) =>
    BrowseProductsModelMeta.fromJson(str);

BrowseProductsModelMetaLinksItem browseProductsModelMetaLinksItemFromJson(
  str,
) => BrowseProductsModelMetaLinksItem.fromJson(str);

String browseProductsModelMetaLinksItemToJson(
  BrowseProductsModelMetaLinksItem data,
) => json.encode(data.toJson());

String browseProductsModelMetaToJson(BrowseProductsModelMeta data) =>
    json.encode(data.toJson());

String browseProductsModelToJson(BrowseProductsModel data) =>
    json.encode(data.toJson());

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

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
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

List<dynamic>? _asDynamicList(dynamic value) {
  if (value is! List) return null;
  return value.map(_asDynamic).toList();
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

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

class BrowseProductsModel {
  List<BrowseProductsModelDataItem>? data;
  BrowseProductsModelLinks? links;
  BrowseProductsModelMeta? meta;

  BrowseProductsModel({this.data, this.links, this.meta});

  factory BrowseProductsModel.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (item) => BrowseProductsModelDataItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
      links: json['links'] is Map
          ? BrowseProductsModelLinks.fromJson(
              Map<String, dynamic>.from(json['links'] as Map),
            )
          : null,
      meta: json['meta'] is Map
          ? BrowseProductsModelMeta.fromJson(
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

class BrowseProductsModelDataItem {
  int? id;
  int? storeId;
  BrowseProductsModelDataItemStore? store;
  int? categoryId;
  BrowseProductsModelDataItemCategory? category;
  int? masterProductId;
  String? name;
  String? barcode;
  String? sourceType;
  dynamic description;
  String? price;
  dynamic discountedPrice;
  bool? isFavorite;
  List<dynamic>? offers;
  BrowseProductsModelDataItemImage? image;
  String? imageUrl;
  List<BrowseProductsModelDataItemImagesItem>? images;
  List<String>? imageUrls;
  int? stockQuantity;
  int? lowStockThreshold;
  dynamic expiresAt;
  bool? isAvailable;
  String? createdAt;
  String? updatedAt;

  BrowseProductsModelDataItem({
    this.id,
    this.storeId,
    this.store,
    this.categoryId,
    this.category,
    this.masterProductId,
    this.name,
    this.barcode,
    this.sourceType,
    this.description,
    this.price,
    this.discountedPrice,
    this.isFavorite,
    this.offers,
    this.image,
    this.imageUrl,
    this.images,
    this.imageUrls,
    this.stockQuantity,
    this.lowStockThreshold,
    this.expiresAt,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory BrowseProductsModelDataItem.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelDataItem(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      store: json['store'] is Map
          ? BrowseProductsModelDataItemStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
      categoryId: _asInt(json['categoryId']),
      category: json['category'] is Map
          ? BrowseProductsModelDataItemCategory.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      masterProductId: _asInt(json['masterProductId']),
      name: _asString(json['name']),
      barcode: _asString(json['barcode']),
      sourceType: _asString(json['sourceType']),
      description: _asDynamic(json['description']),
      price: _asString(json['price']),
      discountedPrice: _asDynamic(json['discountedPrice']),
      isFavorite: _asBool(json['isFavorite']),
      offers: _asDynamicList(json['offers']),
      image: json['image'] is Map
          ? BrowseProductsModelDataItemImage.fromJson(
              Map<String, dynamic>.from(json['image'] as Map),
            )
          : null,
      imageUrl: _asString(json['imageUrl']),
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map(
                  (item) => BrowseProductsModelDataItemImagesItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
      imageUrls: json['imageUrls'] is List
          ? (json['imageUrls'] as List)
                .map((item) => _asString(item))
                .whereType<String>()
                .toList()
          : null,
      stockQuantity: _asInt(json['stockQuantity']),
      lowStockThreshold: _asInt(json['lowStockThreshold']),
      expiresAt: _asDynamic(json['expiresAt']),
      isAvailable: _asBool(json['isAvailable']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'store': store?.toJson(),
      'categoryId': categoryId,
      'category': category?.toJson(),
      'masterProductId': masterProductId,
      'name': name,
      'barcode': barcode,
      'sourceType': sourceType,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'isFavorite': isFavorite,
      'offers': offers,
      'image': image?.toJson(),
      'imageUrl': imageUrl,
      'images': images?.map((item) => item.toJson()).toList(),
      'imageUrls': imageUrls,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'expiresAt': expiresAt,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class BrowseProductsModelDataItemCategory {
  int? id;
  int? storeId;
  String? name;
  String? slug;
  dynamic description;
  int? sortOrder;
  String? imagePath;
  bool? isActive;
  int? productsCount;
  String? createdAt;
  String? updatedAt;

  BrowseProductsModelDataItemCategory({
    this.id,
    this.storeId,
    this.name,
    this.slug,
    this.description,
    this.sortOrder,
    this.imagePath,
    this.isActive,
    this.productsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory BrowseProductsModelDataItemCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return BrowseProductsModelDataItemCategory(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asDynamic(json['description']),
      sortOrder: _asInt(json['sortOrder']),
      imagePath: _asString(json['imagePath']),
      isActive: _asBool(json['isActive']),
      productsCount: _asInt(json['productsCount']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'slug': slug,
      'description': description,
      'sortOrder': sortOrder,
      'imagePath': imagePath,
      'isActive': isActive,
      'productsCount': productsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class BrowseProductsModelDataItemImage {
  int? id;
  String? name;
  String? fileName;
  String? collection;
  String? url;
  String? thumbnailUrl;
  String? size;
  String? extensionValue;
  String? type;
  String? caption;
  String? createdAt;

  BrowseProductsModelDataItemImage({
    this.id,
    this.name,
    this.fileName,
    this.collection,
    this.url,
    this.thumbnailUrl,
    this.size,
    this.extensionValue,
    this.type,
    this.caption,
    this.createdAt,
  });

  factory BrowseProductsModelDataItemImage.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelDataItemImage(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fileName: _asString(json['fileName']),
      collection: _asString(json['collection']),
      url: _asString(json['url']),
      thumbnailUrl: _asString(json['thumbnailUrl']),
      size: _asString(json['size']),
      extensionValue: _asString(json['extension']),
      type: _asString(json['type']),
      caption: _asString(json['caption']),
      createdAt: _asString(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'collection': collection,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'size': size,
      'extension': extensionValue,
      'type': type,
      'caption': caption,
      'createdAt': createdAt,
    };
  }
}

class BrowseProductsModelDataItemImagesItem {
  int? id;
  String? name;
  String? fileName;
  String? collection;
  String? url;
  String? thumbnailUrl;
  String? size;
  String? extensionValue;
  String? type;
  String? caption;
  String? createdAt;

  BrowseProductsModelDataItemImagesItem({
    this.id,
    this.name,
    this.fileName,
    this.collection,
    this.url,
    this.thumbnailUrl,
    this.size,
    this.extensionValue,
    this.type,
    this.caption,
    this.createdAt,
  });

  factory BrowseProductsModelDataItemImagesItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return BrowseProductsModelDataItemImagesItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fileName: _asString(json['fileName']),
      collection: _asString(json['collection']),
      url: _asString(json['url']),
      thumbnailUrl: _asString(json['thumbnailUrl']),
      size: _asString(json['size']),
      extensionValue: _asString(json['extension']),
      type: _asString(json['type']),
      caption: _asString(json['caption']),
      createdAt: _asString(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'collection': collection,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'size': size,
      'extension': extensionValue,
      'type': type,
      'caption': caption,
      'createdAt': createdAt,
    };
  }
}

class BrowseProductsModelDataItemStore {
  int? id;
  int? ownerUserId;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  String? latitude;
  String? longitude;
  String? phone;
  String? email;
  String? cover;
  String? logo;
  String? averageRating;
  int? totalReviews;
  int? trustScore;
  int? warningCount;
  bool? isActive;
  bool? isFeatured;
  bool? isFavorited;
  dynamic suspensionUntil;
  dynamic distanceKm;
  dynamic highestOfferDiscountValue;
  dynamic highestOffer;
  String? createdAt;
  String? updatedAt;

  BrowseProductsModelDataItemStore({
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
    this.isFavorited,
    this.suspensionUntil,
    this.distanceKm,
    this.highestOfferDiscountValue,
    this.highestOffer,
    this.createdAt,
    this.updatedAt,
  });

  factory BrowseProductsModelDataItemStore.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelDataItemStore(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      cover: _asString(json['cover']),
      logo: _asString(json['logo']),
      averageRating: _asString(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      trustScore: _asInt(json['trustScore']),
      warningCount: _asInt(json['warningCount']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isFavorited: _asBool(json['isFavorited']),
      suspensionUntil: _asDynamic(json['suspensionUntil']),
      distanceKm: _asDynamic(json['distanceKm']),
      highestOfferDiscountValue: _asDynamic(json['highestOfferDiscountValue']),
      highestOffer: _asDynamic(json['highestOffer']),
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
      'isFavorited': isFavorited,
      'suspensionUntil': suspensionUntil,
      'distanceKm': distanceKm,
      'highestOfferDiscountValue': highestOfferDiscountValue,
      'highestOffer': highestOffer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class BrowseProductsModelLinks {
  String? first;
  String? last;
  dynamic prev;
  String? next;

  BrowseProductsModelLinks({this.first, this.last, this.prev, this.next});

  factory BrowseProductsModelLinks.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelLinks(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asDynamic(json['prev']),
      next: _asString(json['next']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}

class BrowseProductsModelMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<BrowseProductsModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  BrowseProductsModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory BrowseProductsModelMeta.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List
          ? (json['links'] as List)
                .whereType<Map>()
                .map(
                  (item) => BrowseProductsModelMetaLinksItem.fromJson(
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

class BrowseProductsModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  BrowseProductsModelMetaLinksItem({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory BrowseProductsModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return BrowseProductsModelMetaLinksItem(
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
