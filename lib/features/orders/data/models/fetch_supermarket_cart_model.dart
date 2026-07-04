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

FetchSupermarketCartModel fetchSupermarketCartModelFromJson(str) =>
    FetchSupermarketCartModel.fromJson(str);

String fetchSupermarketCartModelToJson(FetchSupermarketCartModel data) =>
    json.encode(data.toJson());

FetchSupermarketCartModelDataItem fetchSupermarketCartModelDataItemFromJson(
  str,
) => FetchSupermarketCartModelDataItem.fromJson(str);

String fetchSupermarketCartModelDataItemToJson(
  FetchSupermarketCartModelDataItem data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemAmounts
fetchSupermarketCartModelDataItemAmountsFromJson(str) =>
    FetchSupermarketCartModelDataItemAmounts.fromJson(str);

String fetchSupermarketCartModelDataItemAmountsToJson(
  FetchSupermarketCartModelDataItemAmounts data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItem
fetchSupermarketCartModelDataItemItemsItemFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItem.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemToJson(
  FetchSupermarketCartModelDataItemItemsItem data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItemProduct
fetchSupermarketCartModelDataItemItemsItemProductFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItemProduct.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemProductToJson(
  FetchSupermarketCartModelDataItemItemsItemProduct data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItemProductStore
fetchSupermarketCartModelDataItemItemsItemProductStoreFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItemProductStore.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemProductStoreToJson(
  FetchSupermarketCartModelDataItemItemsItemProductStore data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItemProductCategory
fetchSupermarketCartModelDataItemItemsItemProductCategoryFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItemProductCategory.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemProductCategoryToJson(
  FetchSupermarketCartModelDataItemItemsItemProductCategory data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItemStore
fetchSupermarketCartModelDataItemItemsItemStoreFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItemStore.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemStoreToJson(
  FetchSupermarketCartModelDataItemItemsItemStore data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemItemsItemMerchant
fetchSupermarketCartModelDataItemItemsItemMerchantFromJson(str) =>
    FetchSupermarketCartModelDataItemItemsItemMerchant.fromJson(str);

String fetchSupermarketCartModelDataItemItemsItemMerchantToJson(
  FetchSupermarketCartModelDataItemItemsItemMerchant data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemStore
fetchSupermarketCartModelDataItemStoreFromJson(str) =>
    FetchSupermarketCartModelDataItemStore.fromJson(str);

String fetchSupermarketCartModelDataItemStoreToJson(
  FetchSupermarketCartModelDataItemStore data,
) => json.encode(data.toJson());

FetchSupermarketCartModelDataItemMerchant
fetchSupermarketCartModelDataItemMerchantFromJson(str) =>
    FetchSupermarketCartModelDataItemMerchant.fromJson(str);

String fetchSupermarketCartModelDataItemMerchantToJson(
  FetchSupermarketCartModelDataItemMerchant data,
) => json.encode(data.toJson());

class FetchSupermarketCartModel {
  List<FetchSupermarketCartModelDataItem>? data;

  FetchSupermarketCartModel({this.data});

  factory FetchSupermarketCartModel.fromJson(Map<String, dynamic> json) {
    return FetchSupermarketCartModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (item) => FetchSupermarketCartModelDataItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data?.map((item) => item.toJson()).toList()};
  }
}

class FetchSupermarketCartModelDataItem {
  int? id;
  int? storeId;
  int? merchantId;
  FetchSupermarketCartModelDataItemMerchant? merchant;
  FetchSupermarketCartModelDataItemStore? store;
  List<FetchSupermarketCartModelDataItemItemsItem>? items;
  int? productsCount;
  FetchSupermarketCartModelDataItemAmounts? amounts;

  FetchSupermarketCartModelDataItem({
    this.id,
    this.storeId,
    this.merchantId,
    this.merchant,
    this.store,
    this.items,
    this.productsCount,
    this.amounts,
  });

  factory FetchSupermarketCartModelDataItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItem(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      merchantId: _asInt(json['merchantId']),
      merchant: json['merchant'] is Map
          ? FetchSupermarketCartModelDataItemMerchant.fromJson(
              Map<String, dynamic>.from(json['merchant'] as Map),
            )
          : null,
      store: json['store'] is Map
          ? FetchSupermarketCartModelDataItemStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
      items: json['items'] is List
          ? (json['items'] as List)
                .whereType<Map>()
                .map(
                  (item) => FetchSupermarketCartModelDataItemItemsItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : null,
      productsCount: _asInt(json['productsCount']),
      amounts: json['amounts'] is Map
          ? FetchSupermarketCartModelDataItemAmounts.fromJson(
              Map<String, dynamic>.from(json['amounts'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'merchantId': merchantId,
      'merchant': merchant?.toJson(),
      'store': store?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
      'productsCount': productsCount,
      'amounts': amounts?.toJson(),
    };
  }
}

class FetchSupermarketCartModelDataItemAmounts {
  int? subtotal;
  int? total;

  FetchSupermarketCartModelDataItemAmounts({this.subtotal, this.total});

  factory FetchSupermarketCartModelDataItemAmounts.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemAmounts(
      subtotal: _asInt(json['subtotal']),
      total: _asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'subtotal': subtotal, 'total': total};
  }
}

class FetchSupermarketCartModelDataItemItemsItem {
  int? id;
  int? productId;
  int? storeId;
  int? merchantId;
  String? name;
  String? primaryImageUrl;
  String? imageUrl;
  String? primaryImage;
  List<String>? images;
  List<String>? imageUrls;
  int? quantity;
  int? unitPrice;
  int? totalPrice;
  List<dynamic>? modifierIds;
  List<dynamic>? modifiers;
  List<dynamic>? additions;
  List<dynamic>? options;
  List<dynamic>? modifierGroups;
  FetchSupermarketCartModelDataItemItemsItemMerchant? merchant;
  FetchSupermarketCartModelDataItemItemsItemStore? store;
  FetchSupermarketCartModelDataItemItemsItemProduct? product;

  FetchSupermarketCartModelDataItemItemsItem({
    this.id,
    this.productId,
    this.storeId,
    this.merchantId,
    this.name,
    this.primaryImageUrl,
    this.imageUrl,
    this.primaryImage,
    this.images,
    this.imageUrls,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.modifierIds,
    this.modifiers,
    this.additions,
    this.options,
    this.modifierGroups,
    this.merchant,
    this.store,
    this.product,
  });

  factory FetchSupermarketCartModelDataItemItemsItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItem(
      id: _asInt(json['id']),
      productId: _asInt(json['productId']),
      storeId: _asInt(json['storeId']),
      merchantId: _asInt(json['merchantId']),
      name: _asString(json['name']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      imageUrl: _asString(json['imageUrl']),
      primaryImage: _asString(json['primaryImage']),
      images: json['images'] is List
          ? (json['images'] as List)
                .map((item) => _asString(item))
                .whereType<String>()
                .toList()
          : null,
      imageUrls: json['imageUrls'] is List
          ? (json['imageUrls'] as List)
                .map((item) => _asString(item))
                .whereType<String>()
                .toList()
          : null,
      quantity: _asInt(json['quantity']),
      unitPrice: _asInt(json['unitPrice']),
      totalPrice: _asInt(json['totalPrice']),
      modifierIds: _asDynamicList(json['modifierIds']),
      modifiers: _asDynamicList(json['modifiers']),
      additions: _asDynamicList(json['additions']),
      options: _asDynamicList(json['options']),
      modifierGroups: _asDynamicList(json['modifierGroups']),
      merchant: json['merchant'] is Map
          ? FetchSupermarketCartModelDataItemItemsItemMerchant.fromJson(
              Map<String, dynamic>.from(json['merchant'] as Map),
            )
          : null,
      store: json['store'] is Map
          ? FetchSupermarketCartModelDataItemItemsItemStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
      product: json['product'] is Map
          ? FetchSupermarketCartModelDataItemItemsItemProduct.fromJson(
              Map<String, dynamic>.from(json['product'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'storeId': storeId,
      'merchantId': merchantId,
      'name': name,
      'primaryImageUrl': primaryImageUrl,
      'imageUrl': imageUrl,
      'primaryImage': primaryImage,
      'images': images,
      'imageUrls': imageUrls,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'modifierIds': modifierIds,
      'modifiers': modifiers,
      'additions': additions,
      'options': options,
      'modifierGroups': modifierGroups,
      'merchant': merchant?.toJson(),
      'store': store?.toJson(),
      'product': product?.toJson(),
    };
  }
}

class FetchSupermarketCartModelDataItemItemsItemProduct {
  int? id;
  int? storeId;
  int? merchantId;
  int? categoryId;
  FetchSupermarketCartModelDataItemItemsItemProductCategory? category;
  int? masterProductId;
  String? name;
  String? barcode;
  dynamic description;
  int? price;
  int? discountedPrice;
  int? finalPrice;
  dynamic originalPrice;
  bool? hasDiscount;
  String? primaryImageUrl;
  String? imageUrl;
  String? primaryImage;
  List<String>? images;
  List<String>? imageUrls;
  List<dynamic>? additions;
  List<dynamic>? options;
  List<dynamic>? modifierGroups;
  int? stockQuantity;
  int? lowStockThreshold;
  dynamic expiresAt;
  bool? isAvailable;
  FetchSupermarketCartModelDataItemItemsItemProductStore? store;

  FetchSupermarketCartModelDataItemItemsItemProduct({
    this.id,
    this.storeId,
    this.merchantId,
    this.categoryId,
    this.category,
    this.masterProductId,
    this.name,
    this.barcode,
    this.description,
    this.price,
    this.discountedPrice,
    this.finalPrice,
    this.originalPrice,
    this.hasDiscount,
    this.primaryImageUrl,
    this.imageUrl,
    this.primaryImage,
    this.images,
    this.imageUrls,
    this.additions,
    this.options,
    this.modifierGroups,
    this.stockQuantity,
    this.lowStockThreshold,
    this.expiresAt,
    this.isAvailable,
    this.store,
  });

  factory FetchSupermarketCartModelDataItemItemsItemProduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItemProduct(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      merchantId: _asInt(json['merchantId']),
      categoryId: _asInt(json['categoryId']),
      category: json['category'] is Map
          ? FetchSupermarketCartModelDataItemItemsItemProductCategory.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      masterProductId: _asInt(json['masterProductId']),
      name: _asString(json['name']),
      barcode: _asString(json['barcode']),
      description: _asDynamic(json['description']),
      price: _asInt(json['price']),
      discountedPrice: _asInt(json['discountedPrice']),
      finalPrice: _asInt(json['finalPrice']),
      originalPrice: _asDynamic(json['originalPrice']),
      hasDiscount: _asBool(json['hasDiscount']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      imageUrl: _asString(json['imageUrl']),
      primaryImage: _asString(json['primaryImage']),
      images: json['images'] is List
          ? (json['images'] as List)
                .map((item) => _asString(item))
                .whereType<String>()
                .toList()
          : null,
      imageUrls: json['imageUrls'] is List
          ? (json['imageUrls'] as List)
                .map((item) => _asString(item))
                .whereType<String>()
                .toList()
          : null,
      additions: _asDynamicList(json['additions']),
      options: _asDynamicList(json['options']),
      modifierGroups: _asDynamicList(json['modifierGroups']),
      stockQuantity: _asInt(json['stockQuantity']),
      lowStockThreshold: _asInt(json['lowStockThreshold']),
      expiresAt: _asDynamic(json['expiresAt']),
      isAvailable: _asBool(json['isAvailable']),
      store: json['store'] is Map
          ? FetchSupermarketCartModelDataItemItemsItemProductStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'merchantId': merchantId,
      'categoryId': categoryId,
      'category': category?.toJson(),
      'masterProductId': masterProductId,
      'name': name,
      'barcode': barcode,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'finalPrice': finalPrice,
      'originalPrice': originalPrice,
      'hasDiscount': hasDiscount,
      'primaryImageUrl': primaryImageUrl,
      'imageUrl': imageUrl,
      'primaryImage': primaryImage,
      'images': images,
      'imageUrls': imageUrls,
      'additions': additions,
      'options': options,
      'modifierGroups': modifierGroups,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'expiresAt': expiresAt,
      'isAvailable': isAvailable,
      'store': store?.toJson(),
    };
  }
}

class FetchSupermarketCartModelDataItemItemsItemProductStore {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  double? latitude;
  double? longitude;
  String? phone;
  String? email;
  String? logo;
  String? cover;
  String? primaryImageUrl;
  String? logoImageUrl;
  String? bannerImageUrl;
  String? coverImageUrl;
  double? averageRating;
  int? totalReviews;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;

  FetchSupermarketCartModelDataItemItemsItemProductStore({
    this.id,
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
    this.logo,
    this.cover,
    this.primaryImageUrl,
    this.logoImageUrl,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
  });

  factory FetchSupermarketCartModelDataItemItemsItemProductStore.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItemProductStore(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      logo: _asString(json['logo']),
      cover: _asString(json['cover']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      logoImageUrl: _asString(json['logoImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
      coverImageUrl: _asString(json['coverImageUrl']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'logo': logo,
      'cover': cover,
      'primaryImageUrl': primaryImageUrl,
      'logoImageUrl': logoImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'coverImageUrl': coverImageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }
}

class FetchSupermarketCartModelDataItemItemsItemProductCategory {
  int? id;
  String? name;

  FetchSupermarketCartModelDataItemItemsItemProductCategory({
    this.id,
    this.name,
  });

  factory FetchSupermarketCartModelDataItemItemsItemProductCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItemProductCategory(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FetchSupermarketCartModelDataItemItemsItemStore {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  double? latitude;
  double? longitude;
  String? phone;
  String? email;
  String? logo;
  String? cover;
  String? primaryImageUrl;
  String? logoImageUrl;
  String? bannerImageUrl;
  String? coverImageUrl;
  double? averageRating;
  int? totalReviews;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;

  FetchSupermarketCartModelDataItemItemsItemStore({
    this.id,
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
    this.logo,
    this.cover,
    this.primaryImageUrl,
    this.logoImageUrl,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
  });

  factory FetchSupermarketCartModelDataItemItemsItemStore.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItemStore(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      logo: _asString(json['logo']),
      cover: _asString(json['cover']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      logoImageUrl: _asString(json['logoImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
      coverImageUrl: _asString(json['coverImageUrl']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'logo': logo,
      'cover': cover,
      'primaryImageUrl': primaryImageUrl,
      'logoImageUrl': logoImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'coverImageUrl': coverImageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }
}

class FetchSupermarketCartModelDataItemItemsItemMerchant {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  double? latitude;
  double? longitude;
  String? phone;
  String? email;
  String? logo;
  String? cover;
  String? primaryImageUrl;
  String? logoImageUrl;
  String? bannerImageUrl;
  String? coverImageUrl;
  double? averageRating;
  int? totalReviews;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;

  FetchSupermarketCartModelDataItemItemsItemMerchant({
    this.id,
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
    this.logo,
    this.cover,
    this.primaryImageUrl,
    this.logoImageUrl,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
  });

  factory FetchSupermarketCartModelDataItemItemsItemMerchant.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemItemsItemMerchant(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      logo: _asString(json['logo']),
      cover: _asString(json['cover']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      logoImageUrl: _asString(json['logoImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
      coverImageUrl: _asString(json['coverImageUrl']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'logo': logo,
      'cover': cover,
      'primaryImageUrl': primaryImageUrl,
      'logoImageUrl': logoImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'coverImageUrl': coverImageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }
}

class FetchSupermarketCartModelDataItemStore {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  double? latitude;
  double? longitude;
  String? phone;
  String? email;
  String? logo;
  String? cover;
  String? primaryImageUrl;
  String? logoImageUrl;
  String? bannerImageUrl;
  String? coverImageUrl;
  double? averageRating;
  int? totalReviews;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;

  FetchSupermarketCartModelDataItemStore({
    this.id,
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
    this.logo,
    this.cover,
    this.primaryImageUrl,
    this.logoImageUrl,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
  });

  factory FetchSupermarketCartModelDataItemStore.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemStore(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      logo: _asString(json['logo']),
      cover: _asString(json['cover']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      logoImageUrl: _asString(json['logoImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
      coverImageUrl: _asString(json['coverImageUrl']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'logo': logo,
      'cover': cover,
      'primaryImageUrl': primaryImageUrl,
      'logoImageUrl': logoImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'coverImageUrl': coverImageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }
}

class FetchSupermarketCartModelDataItemMerchant {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? address;
  String? city;
  String? neighborhood;
  double? latitude;
  double? longitude;
  String? phone;
  String? email;
  String? logo;
  String? cover;
  String? primaryImageUrl;
  String? logoImageUrl;
  String? bannerImageUrl;
  String? coverImageUrl;
  double? averageRating;
  int? totalReviews;
  bool? isActive;
  bool? isFeatured;
  bool? isTemporarilyClosed;

  FetchSupermarketCartModelDataItemMerchant({
    this.id,
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
    this.logo,
    this.cover,
    this.primaryImageUrl,
    this.logoImageUrl,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.isActive,
    this.isFeatured,
    this.isTemporarilyClosed,
  });

  factory FetchSupermarketCartModelDataItemMerchant.fromJson(
    Map<String, dynamic> json,
  ) {
    return FetchSupermarketCartModelDataItemMerchant(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      logo: _asString(json['logo']),
      cover: _asString(json['cover']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      logoImageUrl: _asString(json['logoImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
      coverImageUrl: _asString(json['coverImageUrl']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'logo': logo,
      'cover': cover,
      'primaryImageUrl': primaryImageUrl,
      'logoImageUrl': logoImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'coverImageUrl': coverImageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }
}
