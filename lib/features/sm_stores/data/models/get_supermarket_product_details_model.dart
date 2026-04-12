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

List<dynamic>? _asDynamicList(dynamic value) {
  if (value is! List) return null;
  return value.map(_asDynamic).toList();
}

GetSupermarketProductDetailsModel getSupermarketProductDetailsModelFromJson(
  dynamic str,
) =>
    GetSupermarketProductDetailsModel.fromJson(
      str is Map<String, dynamic>
          ? str
          : Map<String, dynamic>.from(str as Map),
    );

class GetSupermarketProductDetailsModel {
  SupermarketProductDetailsProduct? product;

  GetSupermarketProductDetailsModel({this.product});

  factory GetSupermarketProductDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['data'] ?? json['product'];
    return GetSupermarketProductDetailsModel(
      product: raw is Map
          ? SupermarketProductDetailsProduct.fromJson(
              Map<String, dynamic>.from(raw),
            )
          : null,
    );
  }
}

class SupermarketProductDetailsProduct {
  int? id;
  int? storeId;
  SupermarketProductDetailsStore? store;
  int? categoryId;
  SupermarketProductDetailsCategory? category;
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
  List<dynamic>? options;
  SupermarketProductDetailsMedia? image;
  String? imageUrl;
  String? primaryImage;
  List<SupermarketProductDetailsMedia>? images;
  List<String>? imageUrls;
  int? stockQuantity;
  int? lowStockThreshold;
  dynamic expiresAt;
  bool? isAvailable;
  String? createdAt;
  String? updatedAt;

  SupermarketProductDetailsProduct({
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
    this.finalPrice,
    this.originalPrice,
    this.hasDiscount,
    this.isFavorite,
    this.offers,
    this.options,
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

  factory SupermarketProductDetailsProduct.fromJson(Map<String, dynamic> json) {
    return SupermarketProductDetailsProduct(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      store: json['store'] is Map
          ? SupermarketProductDetailsStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
      categoryId: _asInt(json['categoryId']),
      category: json['category'] is Map
          ? SupermarketProductDetailsCategory.fromJson(
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
      finalPrice: _asString(json['finalPrice']),
      originalPrice: _asDynamic(json['originalPrice']),
      hasDiscount: _asBool(json['hasDiscount']),
      isFavorite: _asBool(json['isFavorite']),
      offers: _asDynamicList(json['offers']),
      options: _asDynamicList(json['options']),
      image: json['image'] is Map
          ? SupermarketProductDetailsMedia.fromJson(
              Map<String, dynamic>.from(json['image'] as Map),
            )
          : null,
      imageUrl: _asString(json['imageUrl']),
      primaryImage: _asString(json['primaryImage']),
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map(
                  (e) => SupermarketProductDetailsMedia.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      imageUrls: json['imageUrls'] is List
          ? (json['imageUrls'] as List)
                .map((e) => _asString(e))
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
}

class SupermarketProductDetailsStore {
  int? id;
  int? ownerUserId;
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
  dynamic suspensionUntil;
  dynamic distanceKm;
  dynamic highestOfferDiscountValue;
  dynamic highestOffer;
  String? createdAt;
  String? updatedAt;

  SupermarketProductDetailsStore({
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

  factory SupermarketProductDetailsStore.fromJson(Map<String, dynamic> json) {
    return SupermarketProductDetailsStore(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
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
      isFavorited: _asBool(json['isFavorited']),
      suspensionUntil: _asDynamic(json['suspensionUntil']),
      distanceKm: _asDynamic(json['distanceKm']),
      highestOfferDiscountValue: _asDynamic(json['highestOfferDiscountValue']),
      highestOffer: _asDynamic(json['highestOffer']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class SupermarketProductDetailsCategory {
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

  SupermarketProductDetailsCategory({
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

  factory SupermarketProductDetailsCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupermarketProductDetailsCategory(
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
}

class SupermarketProductDetailsMedia {
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

  SupermarketProductDetailsMedia({
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

  factory SupermarketProductDetailsMedia.fromJson(Map<String, dynamic> json) {
    return SupermarketProductDetailsMedia(
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
}
