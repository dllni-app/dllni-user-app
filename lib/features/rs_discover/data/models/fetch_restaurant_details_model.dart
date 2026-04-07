String? _asString(dynamic value) => value == null ? null : '$value';
int? _asInt(dynamic value) =>
    value is int ? value : int.tryParse('${value ?? ''}');
double? _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '${value ?? ''}'.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

num? _asNum(dynamic value) =>
    value is num ? value : num.tryParse('${value ?? ''}');
Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

FetchRestaurantDetailsModel fetchRestaurantDetailsModelFromJson(dynamic json) =>
    FetchRestaurantDetailsModel.fromJson(
      Map<String, dynamic>.from(json as Map),
    );

class FetchRestaurantDetailsModel {
  final RestaurantDetailsRestaurant? restaurant;
  final List<RestaurantDetailsOffer> offers;
  final List<RestaurantDetailsProduct>? popularProducts;
  final List<RestaurantDetailsCategory> categories;
  final RestaurantRatingSummary? ratingSummary;
  final List<RestaurantDetailsReview> reviews;

  FetchRestaurantDetailsModel({
    this.restaurant,
    this.offers = const [],
    this.popularProducts,
    this.categories = const [],
    this.ratingSummary,
    this.reviews = const [],
  });

  factory FetchRestaurantDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantDetailsModel(
      restaurant: json['restaurant'] is Map
          ? RestaurantDetailsRestaurant.fromJson(
              Map<String, dynamic>.from(json['restaurant'] as Map),
            )
          : null,
      offers: _asMapList(
        json['offers'],
      ).map(RestaurantDetailsOffer.fromJson).toList(),
      popularProducts: json['popularProducts'] is List
          ? (json['popularProducts'] as List)
                .whereType<Map>()
                .map(
                  (e) => RestaurantDetailsProduct.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      categories: _asMapList(
        json['categories'],
      ).map(RestaurantDetailsCategory.fromJson).toList(),
      ratingSummary: _asMap(json['ratingSummary']) != null
          ? RestaurantRatingSummary.fromJson(_asMap(json['ratingSummary'])!)
          : null,
      reviews: _asMapList(
        json['reviews'],
      ).map(RestaurantDetailsReview.fromJson).toList(),
    );
  }
}

class RestaurantDetailsRestaurant {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? district;
  final String? locationDetails;
  final int? estimatedPreparationTime;
  final int? totalReviews;
  final bool? isTemporarilyClosed;
  final bool? isFavorited;
  final double? distanceKm;
  final String? primaryImage;
  final String? image;
  final String? imageUrl;
  final String? banner;
  final double? averageRating;
  final List<RestaurantDetailsCuisineType> cuisineTypes;
  final List<RestaurantDetailsOperatingHour> operatingHours;

  RestaurantDetailsRestaurant({
    this.id,
    this.name,
    this.description,
    this.address,
    this.city,
    this.district,
    this.locationDetails,
    this.estimatedPreparationTime,
    this.totalReviews,
    this.isTemporarilyClosed,
    this.isFavorited,
    this.distanceKm,
    this.primaryImage,
    this.image,
    this.imageUrl,
    this.banner,
    this.averageRating,
    this.cuisineTypes = const [],
    this.operatingHours = const [],
  });

  factory RestaurantDetailsRestaurant.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsRestaurant(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      district: _asString(json['district']),
      locationDetails: _asString(json['locationDetails']),
      estimatedPreparationTime: _asInt(json['estimatedPreparationTime']),
      totalReviews: _asInt(json['totalReviews']),
      isTemporarilyClosed: _asBool(json['isTemporarilyClosed']),
      isFavorited: _asBool(json['isFavorited'] ?? json['is_favorited'] ?? json['isFavorite']),
      distanceKm: _asDouble(json['distanceKm']),
      primaryImage: _asString(json['primaryImage']),
      image: _asString(json['image']),
      imageUrl: _asString(json['imageUrl']),
      banner: _asString(json['banner']),
      averageRating: _asDouble(json['averageRating']),
      cuisineTypes: _asMapList(
        json['cuisineTypes'],
      ).map(RestaurantDetailsCuisineType.fromJson).toList(),
      operatingHours: _asMapList(
        json['operatingHours'],
      ).map(RestaurantDetailsOperatingHour.fromJson).toList(),
    );
  }
}

class RestaurantDetailsProduct {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? description;
  final num? price;
  final num? discountedPrice;
  final bool? isFeatured;
  final String? categoryName;
  final String? primaryImage;
  final String? image;
  final String? imageUrl;

  RestaurantDetailsProduct({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.price,
    this.discountedPrice,
    this.isFeatured,
    this.categoryName,
    this.primaryImage,
    this.image,
    this.imageUrl,
  });

  factory RestaurantDetailsProduct.fromJson(Map<String, dynamic> json) {
    final category = _asMap(json['category']);
    return RestaurantDetailsProduct(
      id: _asInt(json['id']),
      categoryId: _asInt(json['categoryId'] ?? json['category_id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      price: _asNum(json['price']),
      discountedPrice: _asNum(
        json['discountedPrice'] ?? json['discounted_price'],
      ),
      isFeatured: _asBool(json['isFeatured'] ?? json['is_featured']),
      categoryName: _asString(category?['name']),
      primaryImage: _asString(json['primaryImage'] ?? json['primary_image']),
      image: _asString(json['image']),
      imageUrl: _asString(json['imageUrl'] ?? json['image_url']),
    );
  }
}

class RestaurantDetailsOffer {
  final int? id;
  final String? name;
  final String? discountType;
  final num? discountValue;

  RestaurantDetailsOffer({
    this.id,
    this.name,
    this.discountType,
    this.discountValue,
  });

  factory RestaurantDetailsOffer.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsOffer(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      discountType: _asString(json['discountType']),
      discountValue: _asNum(json['discountValue']),
    );
  }
}

class RestaurantDetailsCategory {
  final int? id;
  final String? name;
  final List<RestaurantDetailsProduct> products;

  RestaurantDetailsCategory({this.id, this.name, this.products = const []});

  factory RestaurantDetailsCategory.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsCategory(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      products: _asMapList(
        json['products'],
      ).map(RestaurantDetailsProduct.fromJson).toList(),
    );
  }
}

class RestaurantDetailsCuisineType {
  final int? id;
  final String? name;

  RestaurantDetailsCuisineType({this.id, this.name});

  factory RestaurantDetailsCuisineType.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsCuisineType(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }
}

class RestaurantDetailsOperatingHour {
  final String? dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool? isClosed;

  RestaurantDetailsOperatingHour({
    this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed,
  });

  factory RestaurantDetailsOperatingHour.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsOperatingHour(
      dayOfWeek: _asString(json['day_of_week'] ?? json['dayOfWeek']),
      openTime: _asString(json['open_time'] ?? json['openTime']),
      closeTime: _asString(json['close_time'] ?? json['closeTime']),
      isClosed: _asBool(json['is_closed'] ?? json['isClosed']),
    );
  }
}

class RestaurantRatingSummary {
  final double average;
  final int total;
  final Map<int, int> counts;

  RestaurantRatingSummary({
    this.average = 0,
    this.total = 0,
    this.counts = const {},
  });

  factory RestaurantRatingSummary.fromJson(Map<String, dynamic> json) {
    final rawCounts = _asMap(json['counts']) ?? const <String, dynamic>{};
    final parsedCounts = <int, int>{};
    rawCounts.forEach((key, value) {
      final star = _asInt(key);
      if (star == null) return;
      parsedCounts[star] = _asInt(value) ?? 0;
    });

    return RestaurantRatingSummary(
      average: _asDouble(json['average']) ?? 0,
      total: _asInt(json['total']) ?? 0,
      counts: parsedCounts,
    );
  }
}

class RestaurantDetailsReview {
  final String? reviewerName;
  final int rating;
  final String? comment;
  final String? createdAt;

  RestaurantDetailsReview({
    this.reviewerName,
    this.rating = 0,
    this.comment,
    this.createdAt,
  });

  factory RestaurantDetailsReview.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    return RestaurantDetailsReview(
      reviewerName:
          _asString(json['name']) ?? _asString(user?['name']) ?? 'مستخدم',
      rating: _asInt(json['rating']) ?? 0,
      comment: _asString(json['comment'] ?? json['review']),
      createdAt: _asString(json['createdAt'] ?? json['created_at']),
    );
  }
}
