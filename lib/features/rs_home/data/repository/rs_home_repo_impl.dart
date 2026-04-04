import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_home_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../source/rs_home_remote_data_source.dart';
import '../../domain/usecases/fetch_stores_use_case.dart';
import '../models/fetch_stores_model.dart';
import '../../domain/usecases/fetch_near_by_stores_use_case.dart';
import '../models/fetch_near_by_stores_model.dart';
import '../../domain/usecases/fetch_featured_offers_use_case.dart';
import '../models/fetch_featured_offers_model.dart';
import '../../domain/usecases/fetch_restaurant_home_categories_use_case.dart';
import '../models/fetch_restaurant_home_categories_model.dart';
import '../../domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import '../models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../../domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../models/fetch_restaurant_home_suggested_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import '../models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import '../models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_category_products_use_case.dart';
import '../models/fetch_restaurant_home_category_products_model.dart';

@LazySingleton(as: RsHomeRepo)
class RsHomeRepoImpl with HandlingException implements RsHomeRepo {
  final RsHomeRemoteDataSource rsHomeRemoteDataSource;

  RsHomeRepoImpl({required this.rsHomeRemoteDataSource});

  @override
  DataResponse<FetchStoresModel> fetchStores(FetchStoresParams params) {
    return wrapHandlingException(
      tryCall: () => rsHomeRemoteDataSource.fetchStores(params),
    );
  }

  @override
  DataResponse<FetchNearByStoresModel> fetchNearByStores(
    FetchNearByStoresParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsHomeRemoteDataSource.fetchNearByStores(params),
    );
  }

  @override
  DataResponse<FetchFeaturedOffersModel> fetchFeaturedOffers(
    FetchFeaturedOffersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsHomeRemoteDataSource.fetchFeaturedOffers(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeCategoriesModel>
  fetchRestaurantHomeCategories(FetchRestaurantHomeCategoriesParams params) {
    return wrapHandlingException(
      tryCall: () =>
          rsHomeRemoteDataSource.fetchRestaurantHomeCategories(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeExclusiveOffersModel>
  fetchRestaurantHomeExclusiveOffers(
    FetchRestaurantHomeExclusiveOffersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          rsHomeRemoteDataSource.fetchRestaurantHomeExclusiveOffers(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeSuggestedProductsModel>
  fetchRestaurantHomeSuggestedProducts(
    FetchRestaurantHomeSuggestedProductsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          rsHomeRemoteDataSource.fetchRestaurantHomeSuggestedProducts(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeNearestRestaurantsModel>
  fetchRestaurantHomeNearestRestaurants(
    FetchRestaurantHomeNearestRestaurantsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          rsHomeRemoteDataSource.fetchRestaurantHomeNearestRestaurants(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeLatestOrderedProductsModel>
  fetchRestaurantHomeLatestOrderedProducts(
    FetchRestaurantHomeLatestOrderedProductsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsHomeRemoteDataSource
          .fetchRestaurantHomeLatestOrderedProducts(params),
    );
  }

  @override
  DataResponse<FetchRestaurantHomeCategoryProductsModel>
  fetchRestaurantHomeCategoryProducts(
    FetchRestaurantHomeCategoryProductsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          rsHomeRemoteDataSource.fetchRestaurantHomeCategoryProducts(params),
    );
  }
}
