part of 'rs_favourite_bloc.dart';

abstract class RsFavouriteEvent {}

class FetchRsFavouritesEvent extends RsFavouriteEvent with EventWithReload {
  final FetchRsFavouritesParams params;
  final bool loadMore;

  @override
  final bool isReload;

  FetchRsFavouritesEvent({
    required this.params,
    this.isReload = false,
    this.loadMore = false,
  });
}

class FetchFavouriteProductsEvent extends RsFavouriteEvent with EventWithReload {
  final FetchFavouriteProductsParams params;
  final bool loadMore;

  @override
  final bool isReload;

  FetchFavouriteProductsEvent({
    required this.params,
    this.isReload = false,
    this.loadMore = false,
  });
}

class RemoveFavouriteRestaurantEvent extends RsFavouriteEvent {
  final int restaurantId;

  RemoveFavouriteRestaurantEvent({required this.restaurantId});
}

class RemoveFavouriteProductEvent extends RsFavouriteEvent {
  final int productId;

  RemoveFavouriteProductEvent({required this.productId});
}
