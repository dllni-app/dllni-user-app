// Product row embedded in supermarket store-details API (`store.products[]`).
// Kept in `sm_stores` so list UI does not depend on other feature models.

String? _smSummaryAsString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _smSummaryAsInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

bool? _smSummaryAsBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  if (value is String) {
    final n = value.trim().toLowerCase();
    if (n == 'true' || n == '1') return true;
    if (n == 'false' || n == '0') return false;
  }
  return null;
}

dynamic _smSummaryAsDynamic(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.map(_smSummaryAsDynamic).toList();
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((k, v) {
      map['$k'] = _smSummaryAsDynamic(v);
    });
    return map;
  }
  if (value is String || value is num || value is bool) return value;
  return value.toString();
}

class SmStoreProductSummaryImage {
  int? id;
  String? url;

  SmStoreProductSummaryImage({this.id, this.url});

  factory SmStoreProductSummaryImage.fromJson(Map<String, dynamic> json) {
    return SmStoreProductSummaryImage(
      id: _smSummaryAsInt(json['id']),
      url: _smSummaryAsString(json['url']),
    );
  }
}

class SmStoreProductSummary {
  int? id;
  int? categoryId;
  String? name;
  dynamic description;
  String? price;
  dynamic discountedPrice;
  bool? isFavorite;
  String? imageUrl;
  SmStoreProductSummaryImage? image;

  SmStoreProductSummary({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.price,
    this.discountedPrice,
    this.isFavorite,
    this.imageUrl,
    this.image,
  });

  factory SmStoreProductSummary.fromJson(Map<String, dynamic> json) {
    return SmStoreProductSummary(
      id: _smSummaryAsInt(json['id']),
      categoryId: _smSummaryAsInt(json['categoryId']),
      name: _smSummaryAsString(json['name']),
      description: _smSummaryAsDynamic(json['description']),
      price: _smSummaryAsString(json['price']),
      discountedPrice: _smSummaryAsDynamic(json['discountedPrice']),
      isFavorite: _smSummaryAsBool(json['isFavorite']),
      imageUrl: _smSummaryAsString(json['imageUrl']),
      image: json['image'] is Map
          ? SmStoreProductSummaryImage.fromJson(
              Map<String, dynamic>.from(json['image'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'discountedPrice': discountedPrice,
    'isFavorite': isFavorite,
    'imageUrl': imageUrl,
    'image': image == null
        ? null
        : {'id': image!.id, 'url': image!.url},
  };
}
