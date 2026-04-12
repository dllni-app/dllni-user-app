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

GetCompareProductsModel getCompareProductsModelFromJson(str) => GetCompareProductsModel.fromJson(str);

String getCompareProductsModelToJson(GetCompareProductsModel data) => json.encode(data.toJson());


GetCompareProductsModelMeta getCompareProductsModelMetaFromJson(str) => GetCompareProductsModelMeta.fromJson(str);

String getCompareProductsModelMetaToJson(GetCompareProductsModelMeta data) => json.encode(data.toJson());


GetCompareProductsModelMetaLinksItem getCompareProductsModelMetaLinksItemFromJson(str) => GetCompareProductsModelMetaLinksItem.fromJson(str);

String getCompareProductsModelMetaLinksItemToJson(GetCompareProductsModelMetaLinksItem data) => json.encode(data.toJson());


GetCompareProductsModelLinks getCompareProductsModelLinksFromJson(str) => GetCompareProductsModelLinks.fromJson(str);

String getCompareProductsModelLinksToJson(GetCompareProductsModelLinks data) => json.encode(data.toJson());


GetCompareProductsModelDataItem getCompareProductsModelDataItemFromJson(str) => GetCompareProductsModelDataItem.fromJson(str);

String getCompareProductsModelDataItemToJson(GetCompareProductsModelDataItem data) => json.encode(data.toJson());


GetCompareProductsModelDataItemImagesItem getCompareProductsModelDataItemImagesItemFromJson(str) => GetCompareProductsModelDataItemImagesItem.fromJson(str);

String getCompareProductsModelDataItemImagesItemToJson(GetCompareProductsModelDataItemImagesItem data) => json.encode(data.toJson());


GetCompareProductsModelDataItemImage getCompareProductsModelDataItemImageFromJson(str) => GetCompareProductsModelDataItemImage.fromJson(str);

String getCompareProductsModelDataItemImageToJson(GetCompareProductsModelDataItemImage data) => json.encode(data.toJson());


GetCompareProductsModelDataItemCategory getCompareProductsModelDataItemCategoryFromJson(str) => GetCompareProductsModelDataItemCategory.fromJson(str);

String getCompareProductsModelDataItemCategoryToJson(GetCompareProductsModelDataItemCategory data) => json.encode(data.toJson());


class GetCompareProductsModel {
  List<GetCompareProductsModelDataItem>? data;
  GetCompareProductsModelLinks? links;
  GetCompareProductsModelMeta? meta;

  GetCompareProductsModel({
    this.data,
    this.links,
    this.meta,
  });

  factory GetCompareProductsModel.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModel(
      data: json['data'] is List ? (json['data'] as List).whereType<Map>().map((item) => GetCompareProductsModelDataItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      links: json['links'] is Map ? GetCompareProductsModelLinks.fromJson(Map<String, dynamic>.from(json['links'] as Map)) : null,
      meta: json['meta'] is Map ? GetCompareProductsModelMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map)) : null,
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

class GetCompareProductsModelMeta {
  int? currentPage;
  dynamic from;
  int? lastPage;
  List<GetCompareProductsModelMetaLinksItem>? links;
  String? path;
  int? perPage;
  dynamic to;
  int? total;

  GetCompareProductsModelMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory GetCompareProductsModelMeta.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelMeta(
      currentPage: _asInt(json['current_page']),
      from: _asDynamic(json['from']),
      lastPage: _asInt(json['last_page']),
      links: json['links'] is List ? (json['links'] as List).whereType<Map>().map((item) => GetCompareProductsModelMetaLinksItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      path: _asString(json['path']),
      perPage: _asInt(json['per_page']),
      to: _asDynamic(json['to']),
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

class GetCompareProductsModelMetaLinksItem {
  String? url;
  String? label;
  int? page;
  bool? active;

  GetCompareProductsModelMetaLinksItem({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory GetCompareProductsModelMetaLinksItem.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelMetaLinksItem(
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

class GetCompareProductsModelLinks {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  GetCompareProductsModelLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory GetCompareProductsModelLinks.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelLinks(
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

class GetCompareProductsModelDataItem {
  int? id;
  int? storeId;
  int? categoryId;
  GetCompareProductsModelDataItemCategory? category;
  int? masterProductId;
  String? name;
  String? barcode;
  String? sourceType;
  dynamic description;
  String? price;
  dynamic discountedPrice;
  String? finalPrice;
  dynamic originalPrice;
  bool? hasDiscount;
  bool? isFavorite;
  List<dynamic>? offers;
  GetCompareProductsModelDataItemImage? image;
  String? imageUrl;
  String? primaryImage;
  List<GetCompareProductsModelDataItemImagesItem>? images;
  List<String>? imageUrls;
  int? stockQuantity;
  int? lowStockThreshold;
  dynamic expiresAt;
  bool? isAvailable;
  String? createdAt;
  String? updatedAt;

  GetCompareProductsModelDataItem({
    this.id,
    this.storeId,
    this.categoryId,
    this.category,
    this.masterProductId,
    this.name,
    this.barcode,
    this.sourceType,
    this.description,
    this.price,
    this.discountedPrice,
    this.finalPrice,
    this.originalPrice,
    this.hasDiscount,
    this.isFavorite,
    this.offers,
    this.image,
    this.imageUrl,
    this.primaryImage,
    this.images,
    this.imageUrls,
    this.stockQuantity,
    this.lowStockThreshold,
    this.expiresAt,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory GetCompareProductsModelDataItem.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelDataItem(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      categoryId: _asInt(json['categoryId']),
      category: json['category'] is Map ? GetCompareProductsModelDataItemCategory.fromJson(Map<String, dynamic>.from(json['category'] as Map)) : null,
      masterProductId: _asInt(json['masterProductId']),
      name: _asString(json['name']),
      barcode: _asString(json['barcode']),
      sourceType: _asString(json['sourceType']),
      description: _asDynamic(json['description']),
      price: _asString(json['price']),
      discountedPrice: _asDynamic(json['discountedPrice']),
      finalPrice: _asString(json['finalPrice']),
      originalPrice: _asDynamic(json['originalPrice']),
      hasDiscount: _asBool(json['hasDiscount']),
      isFavorite: _asBool(json['isFavorite']),
      offers: _asDynamicList(json['offers']),
      image: json['image'] is Map ? GetCompareProductsModelDataItemImage.fromJson(Map<String, dynamic>.from(json['image'] as Map)) : null,
      imageUrl: _asString(json['imageUrl']),
      primaryImage: _asString(json['primaryImage']),
      images: json['images'] is List ? (json['images'] as List).whereType<Map>().map((item) => GetCompareProductsModelDataItemImagesItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      imageUrls: json['imageUrls'] is List ? (json['imageUrls'] as List).map((item) => _asString(item)).whereType<String>().toList() : null,
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
      'categoryId': categoryId,
      'category': category?.toJson(),
      'masterProductId': masterProductId,
      'name': name,
      'barcode': barcode,
      'sourceType': sourceType,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'finalPrice': finalPrice,
      'originalPrice': originalPrice,
      'hasDiscount': hasDiscount,
      'isFavorite': isFavorite,
      'offers': offers,
      'image': image?.toJson(),
      'imageUrl': imageUrl,
      'primaryImage': primaryImage,
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

class GetCompareProductsModelDataItemImagesItem {
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

  GetCompareProductsModelDataItemImagesItem({
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

  factory GetCompareProductsModelDataItemImagesItem.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelDataItemImagesItem(
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

class GetCompareProductsModelDataItemImage {
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

  GetCompareProductsModelDataItemImage({
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

  factory GetCompareProductsModelDataItemImage.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelDataItemImage(
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

class GetCompareProductsModelDataItemCategory {
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

  GetCompareProductsModelDataItemCategory({
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

  factory GetCompareProductsModelDataItemCategory.fromJson(Map<String, dynamic> json) {
    return GetCompareProductsModelDataItemCategory(
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