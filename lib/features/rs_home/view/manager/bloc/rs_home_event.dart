part of 'rs_home_bloc.dart';

abstract class RsHomeEvent {}

class FetchRestaurantHomeCategoriesEvent extends RsHomeEvent {
  final FetchRestaurantHomeCategoriesParams params;

  FetchRestaurantHomeCategoriesEvent({required this.params});
}

class FetchRestaurantHomeExclusiveOffersEvent extends RsHomeEvent {
  final FetchRestaurantHomeExclusiveOffersParams params;

  FetchRestaurantHomeExclusiveOffersEvent({required this.params});
}

class FetchRestaurantHomeSuggestedProductsEvent extends RsHomeEvent {
  final FetchRestaurantHomeSuggestedProductsParams params;

  FetchRestaurantHomeSuggestedProductsEvent({required this.params});
}

class FetchRestaurantHomeNearestRestaurantsEvent extends RsHomeEvent {
  final FetchRestaurantHomeNearestRestaurantsParams params;

  FetchRestaurantHomeNearestRestaurantsEvent({required this.params});
}

class FetchRestaurantHomeLatestOrderedProductsEvent extends RsHomeEvent {
  final FetchRestaurantHomeLatestOrderedProductsParams params;

  FetchRestaurantHomeLatestOrderedProductsEvent({required this.params});
}

class FetchRestaurantHomeCategoryProductsEvent extends RsHomeEvent {
  final FetchRestaurantHomeCategoryProductsParams params;

  FetchRestaurantHomeCategoryProductsEvent({required this.params});
}

class ReorderLatestOrderedProductEvent extends RsHomeEvent {}

class FetchStoresEvent extends RsHomeEvent with EventWithReload {
  final FetchStoresParams params;
  final bool loadMore;

  @override
  final bool isReload;

  FetchStoresEvent({
    required this.params,
    this.loadMore = false,
    this.isReload = false,
  });
}

class FetchNearByStoresEvent extends RsHomeEvent {
  final FetchNearByStoresParams params;

  FetchNearByStoresEvent({required this.params});
}

class FetchFeaturedOffersEvent extends RsHomeEvent {
  final FetchFeaturedOffersParams params;

  FetchFeaturedOffersEvent({required this.params});
}
