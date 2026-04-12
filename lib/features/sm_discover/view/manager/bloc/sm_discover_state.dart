part of 'sm_discover_bloc.dart';

class SmDiscoverState {
  BlocStatus? changeProductFavoriteStatus;
  ChangeProductFavoriteModel? changeProductFavorite;
  BlocStatus? changeStoreFavoriteStatus;
  ChangeStoreFavoriteModel? changeStoreFavorite;
  PaginationStateModel<BrowseProductsModelDataItem>? browseProducts;
  PaginationStateModel<BrowseStoresModelDataItem>? browseStores;
  String? errorMessage;

  SmDiscoverState({
    this.errorMessage,
    this.browseStores = const PaginationStateModel(perPage: 10),
    this.browseProducts = const PaginationStateModel(perPage: 10),

    this.changeStoreFavorite,
    this.changeStoreFavoriteStatus,
    this.changeProductFavorite,
    this.changeProductFavoriteStatus,
  });

  SmDiscoverState copyWith({
    String? errorMessage,
    PaginationStateModel<BrowseStoresModelDataItem>? browseStores,
    PaginationStateModel<BrowseProductsModelDataItem>? browseProducts,
    ChangeStoreFavoriteModel? changeStoreFavorite,
    BlocStatus? changeStoreFavoriteStatus,
    ChangeProductFavoriteModel? changeProductFavorite,
    BlocStatus? changeProductFavoriteStatus,
  }) => SmDiscoverState(
    errorMessage: errorMessage ?? this.errorMessage,
    browseStores: browseStores ?? this.browseStores,
    browseProducts: browseProducts ?? this.browseProducts,
    changeStoreFavorite: changeStoreFavorite ?? this.changeStoreFavorite,
    changeStoreFavoriteStatus:
        changeStoreFavoriteStatus ?? this.changeStoreFavoriteStatus,
    changeProductFavorite: changeProductFavorite ?? this.changeProductFavorite,
    changeProductFavoriteStatus:
        changeProductFavoriteStatus ?? this.changeProductFavoriteStatus,
  );
}
