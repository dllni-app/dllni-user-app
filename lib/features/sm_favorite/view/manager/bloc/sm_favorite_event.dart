part of 'sm_favorite_bloc.dart';

abstract class SmFavoriteEvent {}

class FetchFavoriteSupermarketStoresEvent extends SmFavoriteEvent
    with EventWithReload {
  final GetFavoriteSupermarketStoresParams params;

  @override
  final bool isReload;

  FetchFavoriteSupermarketStoresEvent({
    required this.params,
    this.isReload = false,
  });
}

class FetchFavoriteSupermarketProductsEvent extends SmFavoriteEvent
    with EventWithReload {
  final GetFavoriteSupermarketProductsParams params;

  @override
  final bool isReload;

  FetchFavoriteSupermarketProductsEvent({
    required this.params,
    this.isReload = false,
  });
}
