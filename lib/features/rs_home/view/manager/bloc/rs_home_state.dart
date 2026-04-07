part of 'rs_home_bloc.dart';

class RsHomeState {
  BlocStatus? restaurantCategoriesStatus;
  FetchRestaurantHomeCategoriesModel? restaurantCategories;
  BlocStatus? restaurantExclusiveOffersStatus;
  FetchRestaurantHomeExclusiveOffersModel? restaurantExclusiveOffers;
  BlocStatus? restaurantSuggestedProductsStatus;
  FetchRestaurantHomeSuggestedProductsModel? restaurantSuggestedProducts;
  BlocStatus? restaurantNearestRestaurantsStatus;
  FetchRestaurantHomeNearestRestaurantsModel? restaurantNearestRestaurants;
  BlocStatus? restaurantLatestOrderedProductsStatus;
  FetchRestaurantHomeLatestOrderedProductsModel?
  restaurantLatestOrderedProducts;
  BlocStatus? restaurantCategoryProductsStatus;
  FetchRestaurantHomeCategoryProductsModel? restaurantCategoryProducts;
  BlocStatus? restaurantReorderStatus;
  BlocStatus? featuredOffersStatus;
  FetchFeaturedOffersModel? featuredOffers;
  BlocStatus? nearByStoresStatus;
  FetchNearByStoresModel? nearByStores;
  PaginationStateModel<FetchStoresModelDataItem>? stores;
  String? errorMessage;

  RsHomeState({
    this.errorMessage,
    this.restaurantCategoriesStatus,
    this.restaurantCategories,
    this.restaurantExclusiveOffersStatus,
    this.restaurantExclusiveOffers,
    this.restaurantSuggestedProductsStatus,
    this.restaurantSuggestedProducts,
    this.restaurantNearestRestaurantsStatus,
    this.restaurantNearestRestaurants,
    this.restaurantLatestOrderedProductsStatus,
    this.restaurantLatestOrderedProducts,
    this.restaurantCategoryProductsStatus,
    this.restaurantCategoryProducts,
    this.restaurantReorderStatus,
    this.stores = const PaginationStateModel(perPage: 10),
    this.nearByStores,
    this.nearByStoresStatus,
    this.featuredOffers,
    this.featuredOffersStatus,
  });

  RsHomeState copyWith({
    String? errorMessage,
    BlocStatus? restaurantCategoriesStatus,
    FetchRestaurantHomeCategoriesModel? restaurantCategories,
    BlocStatus? restaurantExclusiveOffersStatus,
    FetchRestaurantHomeExclusiveOffersModel? restaurantExclusiveOffers,
    BlocStatus? restaurantSuggestedProductsStatus,
    FetchRestaurantHomeSuggestedProductsModel? restaurantSuggestedProducts,
    BlocStatus? restaurantNearestRestaurantsStatus,
    FetchRestaurantHomeNearestRestaurantsModel? restaurantNearestRestaurants,
    BlocStatus? restaurantLatestOrderedProductsStatus,
    FetchRestaurantHomeLatestOrderedProductsModel?
    restaurantLatestOrderedProducts,
    BlocStatus? restaurantCategoryProductsStatus,
    FetchRestaurantHomeCategoryProductsModel? restaurantCategoryProducts,
    BlocStatus? restaurantReorderStatus,
    PaginationStateModel<FetchStoresModelDataItem>? stores,
    FetchNearByStoresModel? nearByStores,
    BlocStatus? nearByStoresStatus,
    FetchFeaturedOffersModel? featuredOffers,
    BlocStatus? featuredOffersStatus,
  }) => RsHomeState(
    errorMessage: errorMessage ?? this.errorMessage,
    restaurantCategoriesStatus:
        restaurantCategoriesStatus ?? this.restaurantCategoriesStatus,
    restaurantCategories: restaurantCategories ?? this.restaurantCategories,
    restaurantExclusiveOffersStatus:
        restaurantExclusiveOffersStatus ?? this.restaurantExclusiveOffersStatus,
    restaurantExclusiveOffers:
        restaurantExclusiveOffers ?? this.restaurantExclusiveOffers,
    restaurantSuggestedProductsStatus:
        restaurantSuggestedProductsStatus ??
        this.restaurantSuggestedProductsStatus,
    restaurantSuggestedProducts:
        restaurantSuggestedProducts ?? this.restaurantSuggestedProducts,
    restaurantNearestRestaurantsStatus:
        restaurantNearestRestaurantsStatus ??
        this.restaurantNearestRestaurantsStatus,
    restaurantNearestRestaurants:
        restaurantNearestRestaurants ?? this.restaurantNearestRestaurants,
    restaurantLatestOrderedProductsStatus:
        restaurantLatestOrderedProductsStatus ??
        this.restaurantLatestOrderedProductsStatus,
    restaurantLatestOrderedProducts:
        restaurantLatestOrderedProducts ?? this.restaurantLatestOrderedProducts,
    restaurantCategoryProductsStatus:
        restaurantCategoryProductsStatus ??
        this.restaurantCategoryProductsStatus,
    restaurantCategoryProducts:
        restaurantCategoryProducts ?? this.restaurantCategoryProducts,
    restaurantReorderStatus:
        restaurantReorderStatus ?? this.restaurantReorderStatus,
    stores: stores ?? this.stores,
    nearByStores: nearByStores ?? this.nearByStores,
    nearByStoresStatus: nearByStoresStatus ?? this.nearByStoresStatus,
    featuredOffers: featuredOffers ?? this.featuredOffers,
    featuredOffersStatus: featuredOffersStatus ?? this.featuredOffersStatus,
  );
}
