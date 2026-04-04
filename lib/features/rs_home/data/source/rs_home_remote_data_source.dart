import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';
import '../models/fetch_stores_model.dart';
import '../../domain/usecases/fetch_stores_use_case.dart';
import '../models/fetch_near_by_stores_model.dart';
import '../../domain/usecases/fetch_near_by_stores_use_case.dart';
import '../models/fetch_featured_offers_model.dart';
import '../../domain/usecases/fetch_featured_offers_use_case.dart';
import '../models/fetch_restaurant_home_categories_model.dart';
import '../../domain/usecases/fetch_restaurant_home_categories_use_case.dart';
import '../models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../../domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import '../models/fetch_restaurant_home_suggested_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import '../models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import '../models/fetch_restaurant_home_category_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_category_products_use_case.dart';

@lazySingleton
class RsHomeRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsHomeRemoteDataSource({required this.dioNetwork});

  Future<FetchStoresModel> fetchStores(FetchStoresParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/stores',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchStoresModelFromJson,
    );
  }

  Future<FetchNearByStoresModel> fetchNearByStores(
    FetchNearByStoresParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/home/nearby-stores',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchNearByStoresModelFromJson,
    );
  }

  Future<FetchFeaturedOffersModel> fetchFeaturedOffers(
    FetchFeaturedOffersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/home/featured-offers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchFeaturedOffersModelFromJson,
    );
  }

  Future<FetchRestaurantHomeCategoriesModel> fetchRestaurantHomeCategories(
    FetchRestaurantHomeCategoriesParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/categories',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeCategoriesModelFromJson,
    );
  }

  Future<FetchRestaurantHomeExclusiveOffersModel>
  fetchRestaurantHomeExclusiveOffers(
    FetchRestaurantHomeExclusiveOffersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/exclusive-offers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeExclusiveOffersModelFromJson,
    );
  }

  Future<FetchRestaurantHomeSuggestedProductsModel>
  fetchRestaurantHomeSuggestedProducts(
    FetchRestaurantHomeSuggestedProductsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/suggested-products',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeSuggestedProductsModelFromJson,
    );
  }

  Future<FetchRestaurantHomeNearestRestaurantsModel>
  fetchRestaurantHomeNearestRestaurants(
    FetchRestaurantHomeNearestRestaurantsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/nearest-restaurants',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeNearestRestaurantsModelFromJson,
    );
  }

  Future<FetchRestaurantHomeLatestOrderedProductsModel>
  fetchRestaurantHomeLatestOrderedProducts(
    FetchRestaurantHomeLatestOrderedProductsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/latest-ordered-products',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeLatestOrderedProductsModelFromJson,
    );
  }

  Future<FetchRestaurantHomeCategoryProductsModel>
  fetchRestaurantHomeCategoryProducts(
    FetchRestaurantHomeCategoryProductsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/home/category-products',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantHomeCategoryProductsModelFromJson,
    );
  }
}
