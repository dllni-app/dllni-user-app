import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_favourite/data/models/fetch_rs_favourites_model.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/fetch_rs_favourites_use_case.dart';
import 'package:dllni_user_app/features/rs_favourite/view/manager/bloc/rs_favourite_bloc.dart';
import 'package:dllni_user_app/features/rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import 'package:dllni_user_app/features/rs_home/view/widgets/store_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'favourite_empty_state.dart';
import 'favourite_restaurant_card_shimmer.dart';

class FavouriteRestaurantsTab extends StatelessWidget {
  const FavouriteRestaurantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RsFavouriteBloc, RsFavouriteState>(
      builder: (context, state) {
        final pagination = state.rsFavourites;

        if (pagination.isFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.labelLarge(pagination.errorMessage),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.read<RsFavouriteBloc>().add(FetchRsFavouritesEvent(params: FetchRsFavouritesParams(page: 1), isReload: true));
                    },
                    child: AppText('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        if (pagination.isLoading && pagination.list.isEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, _) => const FavouriteRestaurantCardShimmer(),
          );
        }

        if (pagination.isEmpty) {
          return RefreshIndicator(
            color: context.primary,
            backgroundColor: context.onPrimary,
            onRefresh: () async {
              context.read<RsFavouriteBloc>().add(FetchRsFavouritesEvent(params: FetchRsFavouritesParams(page: 1), isReload: true));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                FavouriteEmptyState(title: 'لا توجد مطاعم مفضلة حالياً', subtitle: 'أضف مطاعمك المفضلة لتظهر هنا.'),
              ],
            ),
          );
        }

        final showFooter = !pagination.isEndPage && pagination.status == BlocStatus.loading && pagination.list.isNotEmpty;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 240) {
                context.read<RsFavouriteBloc>().add(FetchRsFavouritesEvent(params: FetchRsFavouritesParams(page: 1), loadMore: true));
              }
            }
            return false;
          },
          child: RefreshIndicator(
            color: context.primary,
            backgroundColor: context.onPrimary,
            onRefresh: () async {
              context.read<RsFavouriteBloc>().add(FetchRsFavouritesEvent(params: FetchRsFavouritesParams(page: 1), isReload: true));
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              itemCount: pagination.list.length + (showFooter ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                if (index >= pagination.list.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final store = _mapFavouriteRestaurantToHomeCard(pagination.list[index]);
                return StoreCard(
                  store: store,
                  onFavouriteChanged: (isFavorited) {
                    if (isFavorited) return;
                    final restaurantId = store.id;
                    if (restaurantId == null || restaurantId <= 0) return;
                    context.read<RsFavouriteBloc>().add(
                      RemoveFavouriteRestaurantEvent(restaurantId: restaurantId),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

RestaurantHomeNearestRestaurantItem _mapFavouriteRestaurantToHomeCard(FetchRsFavouritesModelDataItem item) {
  final cuisineNames = item.cuisineTypes?.map((c) => (c.name ?? '').trim()).where((name) => name.isNotEmpty).toList();

  final estimatedMax = item.estimatedPreparationTime;
  final int? estimatedMin = estimatedMax == null ? null : (estimatedMax - 10).clamp(1, estimatedMax).toInt();

  return RestaurantHomeNearestRestaurantItem(
    id: item.id,
    name: item.name,
    slug: item.slug,
    rating: item.averageRating?.toDouble(),
    primaryImageUrl: item.imageUrl ?? item.primaryImage ?? item.image,
    cuisineNames: cuisineNames,
    cuisineSummary: cuisineNames?.join(' • ') ?? item.description,
    distanceKm: _asDouble(item.distanceKm),
    distanceUnit: 'km',
    estimatedDeliveryMinutesMin: estimatedMin,
    estimatedDeliveryMinutesMax: estimatedMax,
    discountOfferBadge: item.listingOffer?.offerBadgeText,
    popularOrdersCount: item.totalReviews,
    isFavorited: true,
    deliveryFee: item.minimumOrderAmount,
    currency: 'د.أ',
  );
}

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
