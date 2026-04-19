import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../domain/repository/rs_discover_repo.dart';
import '../../domain/params/fetch_discover_restaurants_params.dart';
import '../../domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../models/add_restaurant_cart_item_model.dart';
import '../models/fetch_restaurant_cart_products_count_model.dart';
import '../models/fetch_discover_restaurants_model.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/fetch_restaurant_product_details_use_case.dart';
import '../models/fetch_restaurant_product_details_model.dart';
import '../../domain/usecases/fetch_restaurant_products_search_use_case.dart';
import '../models/fetch_restaurant_products_search_model.dart';
import '../source/rs_discover_remote_data_source.dart';

@LazySingleton(as: RsDiscoverRepo)
class RsDiscoverRepoImpl with HandlingException implements RsDiscoverRepo {
  final RsDiscoverRemoteDataSource rsDiscoverRemoteDataSource;

  RsDiscoverRepoImpl({required this.rsDiscoverRemoteDataSource});

  @override
  DataResponse<FetchDiscoverRestaurantsModel> fetchDiscoverRestaurants(
    FetchDiscoverRestaurantsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          rsDiscoverRemoteDataSource.fetchDiscoverRestaurants(params),
    );
  }

  @override
  DataResponse<FetchRestaurantDetailsModel> fetchRestaurantDetails(
    FetchRestaurantDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsDiscoverRemoteDataSource.fetchRestaurantDetails(params),
    );
  }

  @override
  DataResponse<FetchRestaurantProductDetailsModel>
  fetchRestaurantProductDetails(FetchRestaurantProductDetailsParams params) {
    return wrapHandlingException(
      tryCall: () =>
          rsDiscoverRemoteDataSource.fetchRestaurantProductDetails(params),
    );
  }

  @override
  DataResponse<FetchRestaurantProductsSearchModel>
  fetchRestaurantProductsSearch(FetchRestaurantProductsSearchParams params) {
    return wrapHandlingException(
      tryCall: () =>
          rsDiscoverRemoteDataSource.fetchRestaurantProductsSearch(params),
    );
  }

  @override
  DataResponse<AddRestaurantCartItemModel> addRestaurantCartItem(
    AddRestaurantCartItemParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsDiscoverRemoteDataSource.addRestaurantCartItem(params),
    );
  }

  @override
  DataResponse<FetchRestaurantCartProductsCountModel>
  fetchRestaurantCartProductsCount() {
    return wrapHandlingException(
      tryCall: () =>
          rsDiscoverRemoteDataSource.fetchRestaurantCartProductsCount(),
    );
  }
}
