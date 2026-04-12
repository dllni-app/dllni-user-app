part of 'sm_favorite_bloc.dart';

class SmFavoriteState {
  PaginationStateModel<BrowseStoresModelDataItem>? favoriteStores;
  PaginationStateModel<BrowseProductsModelDataItem>? favoriteProducts;
  String? errorMessage;

  SmFavoriteState({
    this.favoriteStores = const PaginationStateModel(perPage: 10),
    this.favoriteProducts = const PaginationStateModel(perPage: 10),
    this.errorMessage,
  });

  SmFavoriteState copyWith({
    PaginationStateModel<BrowseStoresModelDataItem>? favoriteStores,
    PaginationStateModel<BrowseProductsModelDataItem>? favoriteProducts,
    String? errorMessage,
  }) => SmFavoriteState(
    favoriteStores: favoriteStores ?? this.favoriteStores,
    favoriteProducts: favoriteProducts ?? this.favoriteProducts,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
