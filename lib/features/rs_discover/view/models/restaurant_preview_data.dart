import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';

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
  });

  factory RestaurantPreviewData.fromHomeNearest(
    RestaurantHomeNearestRestaurantItem store,
  ) {
    final image = (store.primaryImageUrl ?? '').trim();
    final distance = store.distanceKm == null
        ? null
        : '${store.distanceKm!.toStringAsFixed(1)} كم';
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
    );
  }

  factory RestaurantPreviewData.fromDiscover(
    FetchDiscoverRestaurantsModelDataItem store,
  ) {
    String? pickImage() {
      final imageUrl = (store.imageUrl ?? '').trim();
      if (imageUrl.isNotEmpty) return imageUrl;
      final primary = (store.primaryImage ?? '').trim();
      if (primary.isNotEmpty) return primary;
      final image = (store.image ?? '').trim();
      if (image.isNotEmpty) return image;
      return null;
    }

    final cuisineSummary =
        store.cuisineTypes
            ?.map((e) => e.name)
            .whereType<String>()
            .where((e) => e.trim().isNotEmpty)
            .join(' • ') ??
        '';

    final distance = store.distanceKm == null
        ? null
        : '${store.distanceKm!.toStringAsFixed(1)} كم';

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
    );
  }
}
