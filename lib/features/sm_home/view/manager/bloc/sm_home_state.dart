part of 'sm_home_bloc.dart';

class SmHomeState {
  BlocStatus? changeStoreFavoriteStatus;
  ChangeStoreFavoriteModel? changeStoreFavorite;
  BlocStatus? nearbyStoresStatus;
  GetNearbyStoresModel? nearbyStores;
  BlocStatus? featuredOffersStatus;
  GetFeaturedOffersModel? featuredOffers;
  String? errorMessage;

  SmHomeState({
    this.errorMessage,
    this.featuredOffers,
    this.featuredOffersStatus,
    this.nearbyStores,
    this.nearbyStoresStatus,
    this.changeStoreFavorite,
    this.changeStoreFavoriteStatus,
  });

  SmHomeState copyWith({
    String? errorMessage,
    GetFeaturedOffersModel? featuredOffers,
    BlocStatus? featuredOffersStatus,
    GetNearbyStoresModel? nearbyStores,
    BlocStatus? nearbyStoresStatus,
    ChangeStoreFavoriteModel? changeStoreFavorite,
    BlocStatus? changeStoreFavoriteStatus,
  }) => SmHomeState(
    errorMessage: errorMessage ?? this.errorMessage,
    featuredOffers: featuredOffers ?? this.featuredOffers,
    featuredOffersStatus: featuredOffersStatus ?? this.featuredOffersStatus,
    nearbyStores: nearbyStores ?? this.nearbyStores,
    nearbyStoresStatus: nearbyStoresStatus ?? this.nearbyStoresStatus,
    changeStoreFavorite: changeStoreFavorite ?? this.changeStoreFavorite,
    changeStoreFavoriteStatus:
        changeStoreFavoriteStatus ?? this.changeStoreFavoriteStatus,
  );
}
