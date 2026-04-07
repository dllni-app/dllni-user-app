import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_exclusive_offers_model.dart';

class RestaurantPreviewData {
  final int restaurantId;
  final String name;
  final String description;
  final String? imageUrl;
  final double? rating;
  final int? totalReviews;
  final String? cuisineSummary;
  final String? address;
  final String? distanceLabel;
  final int? estimatedPreparationTime;
  final bool? isFavorited;

  const RestaurantPreviewData({
    required this.restaurantId,
    required this.name,
    required this.description,
    this.imageUrl,
    this.rating,
    this.totalReviews,
    this.cuisineSummary,
    this.address,
    this.distanceLabel,
    this.estimatedPreparationTime,
    this.isFavorited,
  });

  RestaurantPreviewData copyWith({
    int? restaurantId,
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    String? cuisineSummary,
    String? address,
    String? distanceLabel,
    int? estimatedPreparationTime,
    bool? isFavorited,
  }) {
    return RestaurantPreviewData(
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      cuisineSummary: cuisineSummary ?? this.cuisineSummary,
      address: address ?? this.address,
      distanceLabel: distanceLabel ?? this.distanceLabel,
      estimatedPreparationTime: estimatedPreparationTime ?? this.estimatedPreparationTime,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  factory RestaurantPreviewData.fromHomeNearest(RestaurantHomeNearestRestaurantItem store) {
    final image = (store.primaryImageUrl ?? '').trim();
    final distance = store.distanceKm == null ? null : '${store.distanceKm!.toStringAsFixed(1)} كم';
    return RestaurantPreviewData(
      restaurantId: store.id ?? 0,
      name: (store.name ?? '').trim(),
      description: (store.cuisineSummary ?? '').trim(),
      imageUrl: image.isEmpty ? null : image,
      rating: store.rating,
      totalReviews: store.popularOrdersCount,
      cuisineSummary: store.cuisineSummary,
      address: null,
      distanceLabel: distance,
      estimatedPreparationTime: store.estimatedDeliveryMinutesMax,
      isFavorited: store.isFavorited,
    );
  }

  factory RestaurantPreviewData.fromDiscover(FetchDiscoverRestaurantsModelDataItem store) {
    String? pickImage() {
      final imageUrl = (store.imageUrl ?? '').trim();
      if (imageUrl.isNotEmpty) return imageUrl;
      final primary = (store.primaryImage ?? '').trim();
      if (primary.isNotEmpty) return primary;
      final image = (store.image ?? '').trim();
      if (image.isNotEmpty) return image;
      return null;
    }

    final cuisineSummary = store.cuisineTypes?.map((e) => e.name).whereType<String>().where((e) => e.trim().isNotEmpty).join(' • ') ?? '';

    final distance = store.distanceKm == null ? null : '${store.distanceKm!.toStringAsFixed(1)} كم';

    return RestaurantPreviewData(
      restaurantId: store.id ?? 0,
      name: (store.name ?? '').trim(),
      description: (store.description ?? '').trim(),
      imageUrl: pickImage(),
      rating: store.averageRating,
      totalReviews: store.totalReviews,
      cuisineSummary: cuisineSummary.isEmpty ? null : cuisineSummary,
      address: (store.address ?? '').trim().isEmpty ? null : store.address,
      distanceLabel: distance,
      estimatedPreparationTime: store.estimatedPreparationTime,
      isFavorited: store.isFavorited,
    );
  }

  factory RestaurantPreviewData.fromHomeExclusiveOfferRestaurant(
    RestaurantHomeExclusiveOfferRestaurant restaurant,
  ) {
    final image = (restaurant.imageUrl ?? '').trim();
    final primary = (restaurant.primaryImage ?? '').trim();
    final fallbackImage = (restaurant.image ?? '').trim();
    final distance = restaurant.distanceKm == null ? null : '${restaurant.distanceKm!.toStringAsFixed(1)} كم';

    return RestaurantPreviewData(
      restaurantId: restaurant.id ?? 0,
      name: (restaurant.name ?? '').trim(),
      description: (restaurant.description ?? '').trim(),
      imageUrl: image.isNotEmpty
          ? image
          : (primary.isNotEmpty
                ? primary
                : (fallbackImage.isNotEmpty ? fallbackImage : null)),
      rating: restaurant.averageRating,
      totalReviews: restaurant.totalReviews,
      cuisineSummary: null,
      address: (restaurant.address ?? '').trim().isEmpty ? null : restaurant.address,
      distanceLabel: distance,
      estimatedPreparationTime: restaurant.estimatedPreparationTime,
      isFavorited: restaurant.isFavorited,
    );
  }
}
